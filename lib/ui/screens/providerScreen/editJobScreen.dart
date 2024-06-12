import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditJobScreen extends StatefulWidget {
  final QueryDocumentSnapshot job;

  const EditJobScreen({Key? key, required this.job}) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late TextEditingController _salaryController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job['title']);
    _descriptionController = TextEditingController(text: widget.job['description']);
    _typeController = TextEditingController(text: widget.job['type']);
    _salaryController = TextEditingController(text: widget.job['salary']);
    _categoryController = TextEditingController(text: widget.job['category']);
    _locationController = TextEditingController(text: widget.job['location']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _salaryController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateJob() async {
    await FirebaseFirestore.instance.collection('job_posted').doc(widget.job.id).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'type': _typeController.text,
      'salary': _salaryController.text,
      'category': _categoryController.text,
      'location': _locationController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Job'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _updateJob,
                  child: Text('Update Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
