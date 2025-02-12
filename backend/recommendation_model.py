from flask import Flask, jsonify, request
from flask_cors import CORS
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin
cred = credentials.Certificate('backend/athenna-path-firebase-adminsdk-fbsvc-66aee139e2.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def get_user_interactions():
    # Get user search history
    search_data = []
    searches = db.collection('user_searches').get()
    for search in searches:
        search_data.append({
            'userId': search.get('userId'),
            'query': search.get('query'),
            'timestamp': search.get('timestamp')
        })
    
    # Get user course views
    view_data = []
    views = db.collection('user_course_views').get()
    for view in views:
        view_data.append({
            'userId': view.get('userId'),
            'courseId': view.get('courseId'),
            'timestamp': view.get('timestamp')
        })
    
    return pd.DataFrame(search_data), pd.DataFrame(view_data)

def get_recommendations(user_id, num_recommendations=5):
    # Get user interaction data
    search_df, view_df = get_user_interactions()
    
    # Get user's recent searches
    user_searches = search_df[search_df['userId'] == user_id]['query'].tolist()
    
    # Get user's viewed courses
    user_views = view_df[view_df['userId'] == user_id]['courseId'].tolist()
    
    # Get similar users based on search patterns
    if user_searches:
        # Create TF-IDF matrix of search queries
        tfidf = TfidfVectorizer(stop_words='english')
        search_matrix = tfidf.fit_transform(search_df['query'])
        
        # Find similar users based on search patterns
        user_searches_combined = ' '.join(user_searches)
        user_vector = tfidf.transform([user_searches_combined])
        
        # Calculate similarity with other users
        sim_scores = cosine_similarity(user_vector, search_matrix)
        
        # Get similar users
        similar_user_indices = sim_scores[0].argsort()[::-1][1:6]  # Top 5 similar users
        similar_users = search_df.iloc[similar_user_indices]['userId'].unique()
        
        # Get courses viewed by similar users
        recommended_courses = view_df[view_df['userId'].isin(similar_users)]['courseId'].unique()
        
        # Remove courses already viewed by the user
        recommended_courses = [c for c in recommended_courses if c not in user_views]
        
        return recommended_courses[:num_recommendations]
    
    return []

@app.route('/api/recommendations', methods=['POST'])
def recommend_courses():
    try:
        user_data = request.json
        user_id = user_data.get('userId')
        
        if not user_id:
            return jsonify({
                'status': 'error',
                'message': 'User ID is required'
            }), 400
        
        recommendations = get_recommendations(user_id)
        
        return jsonify({
            'status': 'success',
            'recommendations': recommendations
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/courses/search/<query>', methods=['GET'])
def search_courses():
    try:
        # Get the search query from the request
        query = request.args.get('query', '')
        
        # Get courses from Firebase
        courses_ref = db.collection('courses')
        courses = courses_ref.get()
        
        # Filter courses based on query
        search_results = []
        for course in courses:
            course_data = course.to_dict()
            if query.lower() in course_data.get('title', '').lower() or \
               query.lower() in course_data.get('description', '').lower():
                search_results.append(course_data)
        
        return jsonify(search_results)
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500
    


if __name__ == '__main__':
    app.run(debug=True, port=5000) 