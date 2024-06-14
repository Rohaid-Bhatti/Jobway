import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class CreateCVScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String userId;

  const CreateCVScreen({super.key, this.userData, required this.userId});

  @override
  State<CreateCVScreen> createState() => _CreateCVScreenState();
}

class _CreateCVScreenState extends State<CreateCVScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  Future<void> _saveCV() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate PDF
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CV', style: pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 16),
                  pw.Text('Name: ${widget.userData?['name']}', style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Email: ${widget.userData?['email']}', style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Phone: ${widget.userData?['number']}', style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Location: ${widget.userData?['location']}', style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Designation: ${widget.userData?['designation']}', style: pw.TextStyle(fontSize: 18)),
                  pw.SizedBox(height: 16),
                  pw.Text('Summary:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_summaryController.text, style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),
                  pw.Text('Experience:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_experienceController.text, style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),
                  pw.Text('Education:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_educationController.text, style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),
                  pw.Text('Skills:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_skillsController.text, style: pw.TextStyle(fontSize: 16)),
                ],
              );
            },
          ),
        );

        // Save PDF to local storage
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/cv.pdf');
        await file.writeAsBytes(await pdf.save());

        // Upload PDF to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${widget.userId}/cv.pdf');
        await storageRef.putFile(file);

        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Save the download URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({'cv_pdf_url': downloadUrl});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CV saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save CV. Please try again later.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create CV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _summaryController,
                  decoration: InputDecoration(labelText: 'Summary'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a summary';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: InputDecoration(labelText: 'Experience'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your experience';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _educationController,
                  decoration: InputDecoration(labelText: 'Education'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your education';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: InputDecoration(labelText: 'Skills'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your skills';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveCV,
                    child: Text('Save CV'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
