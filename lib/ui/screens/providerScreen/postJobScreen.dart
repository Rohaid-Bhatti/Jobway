import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _responsibilityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? _selectedJobType;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _responsibilityController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the current user's UID
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You need to be logged in to post a job')),
          );
          return;
        }

        // Fetch picture and about from users collection
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final picture = userDoc['picture'];
        final about = userDoc['about'];
        final number = userDoc['number'];
        final email = userDoc['email'];

        // Create a new document reference
        DocumentReference jobDocRef = FirebaseFirestore.instance.collection('job_posted').doc();
        String docId = jobDocRef.id;

        // Upload job post to Firestore with document ID
        await jobDocRef.set({
          'documentId': docId, // Store the document ID in the document itself
          'title': _titleController.text,
          'description': _descriptionController.text,
          'responsibility': _responsibilityController.text,
          'location': _locationController.text,
          'salary': _salaryController.text,
          'type': _selectedJobType,
          'category': _categoryController.text,
          'picture': picture,
          'about': about,
          'number': number,
          'email': email,
          'postedAt': FieldValue.serverTimestamp(),
          'uid': user.uid, // Add the user's UID
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job Posted Successfully!')),
        );

        // Clear the form fields
        _titleController.clear();
        _descriptionController.clear();
        _responsibilityController.clear();
        _locationController.clear();
        _salaryController.clear();
        setState(() {
          _selectedJobType = null;
        });
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post job: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Job', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Job Title'),
              SizedBox(height: 16),
              _buildTextField(_salaryController, 'Salary', keyboardType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_categoryController, 'Category'),
              SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Job Description', maxLines: 5),
              SizedBox(height: 16),
              _buildTextField(_responsibilityController, 'Responsibilities', maxLines: 5),
              SizedBox(height: 16),
              _buildTextField(_locationController, 'Location'),
              SizedBox(height: 16),
              _buildDropdownField(['Full-time', 'Part-time', 'Internship']),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _postJob();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text('Post Job', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(List<String> items) {
    return InputDecorator(
      decoration: InputDecoration(
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: 'Type',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJobType,
          isDense: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedJobType = newValue;
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
