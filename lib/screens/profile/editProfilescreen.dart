import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';

class EditProfile extends StatefulWidget {
  final Student student;

  const EditProfile({Key? key, required this.student}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseService _firebaseService = FirebaseService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isSaving = false;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController dateOfBirthController;
  late TextEditingController descriptionController;
  String selectedGender = '';
  List<Project> projects = [];
  List<Course> courses = [];
  File? profileImage;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.student.firstName);
    lastNameController = TextEditingController(text: widget.student.lastName);
    phoneNumberController =
        TextEditingController(text: widget.student.phoneNumber);
    dateOfBirthController =
        TextEditingController(text: widget.student.dateOfBirth);
    descriptionController =
        TextEditingController(text: widget.student.description);
    selectedGender = widget.student.gender;
    projects = widget.student.projects;
    courses = widget.student.courses;

    if (widget.student.profilePicture.isNotEmpty) {
      profileImage = File(widget.student.profilePicture);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  void saveProfile() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create updated student object
      final updatedStudent = Student(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: currentUser!.email ?? '',
        phoneNumber: phoneNumberController.text,
        dateOfBirth: dateOfBirthController.text,
        description: descriptionController.text,
        gender: selectedGender,
        profilePicture: profileImage?.path ?? widget.student.profilePicture,
        projects: projects,
        courses: courses,
      );

      // Update in Firebase
      await _firebaseService.updateStudentProfile(
        currentUser!.uid,
        updatedStudent,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updatedStudent);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF2E3F66),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: pickImage,
                    child: const Text("Add Picture"),
                  ),
                ),
                const SizedBox(height: 16.0),
                buildLabel("First Name"),
                buildTextField(firstNameController, "What's your first name?"),
                const SizedBox(height: 10.0),
                buildLabel("Last Name"),
                buildTextField(lastNameController, "And your last name?"),
                const SizedBox(height: 10.0),
                buildLabel("Phone Number"),
                buildTextField(phoneNumberController, "Phone number"),
                const SizedBox(height: 10.0),
                buildLabel("Gender"),
                DropdownButtonFormField<String>(
                  value: selectedGender.isNotEmpty ? selectedGender : null,
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value ?? '';
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10.0),
                buildLabel("Date of Birth"),
                buildTextField(
                    dateOfBirthController, "What is your date of birth?"),
                const SizedBox(height: 10.0),
                buildLabel("Description"),
                buildTextField(descriptionController, "Description"),
                const SizedBox(height: 20.0),
                buildSectionHeader("Projects"),
                ...projects
                    .map((project) =>
                        buildListItem(project.title, project.description))
                    .toList(),
                IconButton(
                  onPressed: addNewProject,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const SizedBox(height: 20.0),
                buildSectionHeader("Courses Completed"),
                ...courses
                    .map((course) =>
                        buildListItem(course.title, course.instructor))
                    .toList(),
                IconButton(
                  onPressed: addNewCourse,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3F66),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save Profile",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }

  Widget buildListItem(String title, String description) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
    );
  }

  void addNewProject() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Project Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Project Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    projects.add(Project(
                      title: titleController.text,
                      description: descriptionController.text,
                    ));
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save Project"),
              ),
            ],
          ),
        );
      },
    );
  }

  void addNewCourse() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController instructorController =
            TextEditingController();
        final TextEditingController dateController = TextEditingController();
        final TextEditingController durationController =
            TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Course Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: instructorController,
                decoration: InputDecoration(
                  hintText: 'Instructor Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Course Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  hintText: 'Course Duration',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    courses.add(Course(
                      title: titleController.text,
                      instructor: instructorController.text,
                      date: dateController.text,
                      duration: durationController.text,
                    ));
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save Course"),
              ),
            ],
          ),
        );
      },
    );
  }
}
