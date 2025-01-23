import 'package:final_project/common-widgets/appbar.dart';
import 'package:final_project/common-widgets/sidebar.dart';
import 'package:flutter/material.dart';

class MockTest extends StatefulWidget {
  const MockTest({Key? key}) : super(key: key);

  @override
  State<MockTest> createState() => _MockTestState();
}

class _MockTestState extends State<MockTest> {
  bool testStarted = false;
  int currentQuestionIndex = 0;
  int score = 0;
  final PageController _pageController = PageController();
  List<int?> userAnswers = List.filled(10, null);

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'If 2x + 3 = 11, what is the value of x?',
      'options': ['3', '4', '5', '6'],
      'correctAnswer': 0,
    },
    {
      'question': 'What comes next in the sequence: 2, 4, 8, 16, ...',
      'options': ['20', '24', '32', '36'],
      'correctAnswer': 2,
    },
    {
      'question': 'If a train travels 300 km in 4 hours, what is its speed in km/h?',
      'options': ['60', '65', '70', '75'],
      'correctAnswer': 3,
    },
    {
      'question': 'What is 15% of 200?',
      'options': ['25', '30', '35', '40'],
      'correctAnswer': 1,
    },
    {
      'question': 'If 3x + 2y = 12 and y = 3, what is x?',
      'options': ['1', '2', '3', '4'],
      'correctAnswer': 1,
    },
    {
      'question': 'Complete the series: 1, 4, 9, 16, ...',
      'options': ['20', '23', '25', '36'],
      'correctAnswer': 3,
    },
    {
      'question': 'If a = 2 and b = 3, what is 2a + 3b?',
      'options': ['11', '12', '13', '14'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the square root of 144?',
      'options': ['10', '11', '12', '13'],
      'correctAnswer': 2,
    },
    {
      'question': 'If 4x = 20, what is x?',
      'options': ['4', '5', '6', '7'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is 25% of 80?',
      'options': ['15', '20', '25', '30'],
      'correctAnswer': 1,
    },
  ];

  void calculateScore() {
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        score++;
      }
    }
  }

  Widget buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz,
            size: 100,
            color: Color(0xFF2E3F66),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aptitude Mock Test',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3F66),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '10 Questions • 10 Minutes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E3F66),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              setState(() {
                testStarted = true;
              });
            },
            child: const Text(
              'GET STARTED',
              style: TextStyle(fontSize: 18,color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestionScreen() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / questions.length,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFF2E3F66),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentQuestionIndex = index;
              });
            },
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}/10',
                      style: const TextStyle(
                        color: Color(0xFF2E3F66),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      questions[index]['question'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...List.generate(
                      4,
                      (optionIndex) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              userAnswers[index] = optionIndex;
                            });
                            if (index < questions.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: userAnswers[index] == optionIndex
                                    ? const Color(0xFF2E3F66)
                                    : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: userAnswers[index] == optionIndex
                                  ? const Color(0xFF2E3F66).withOpacity(0.1)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${String.fromCharCode(65 + optionIndex)}.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: userAnswers[index] == optionIndex
                                        ? const Color(0xFF2E3F66)
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  questions[index]['options'][optionIndex],
                                  style: TextStyle(
                                    color: userAnswers[index] == optionIndex
                                        ? const Color(0xFF2E3F66)
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (index == questions.length - 1)
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3F66),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            calculateScore();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text('Test Complete!'),
                                content: Text(
                                  'Your score: $score out of ${questions.length}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        testStarted = false;
                                        currentQuestionIndex = 0;
                                        userAnswers = List.filled(10, null);
                                        score = 0;
                                      });
                                    },
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Submit Test',
                            style: TextStyle(fontSize: 18,color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuSidebar(),
      appBar: AppBarWidget(),
      body: testStarted ? buildQuestionScreen() : buildStartScreen(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}