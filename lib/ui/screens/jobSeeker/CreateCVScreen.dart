import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
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
  bool _cvExists = false;
  String? _cvDownloadUrl;

  @override
  void initState() {
    super.initState();
    // Check if CV already exists for this user
    _checkIfCVExists();
  }

  Future<void> _checkIfCVExists() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(/*widget.userData['uid']*/ widget.userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data()! as Map<String, dynamic>;
        var cvPdfUrl = userData['cv_pdf_url'] as String?;

        if (cvPdfUrl != null && cvPdfUrl.isNotEmpty) {
          setState(() {
            _cvExists = true;
            _cvDownloadUrl = cvPdfUrl;
          });
        } else {
          setState(() {
            _cvExists = false;
          });
        }
      } else {
        setState(() {
          _cvExists = false;
        });
      }
    } catch (e) {
      print('Error checking CV existence: $e');
      setState(() {
        _cvExists = false;
      });
    }
  }

  /*Future<void> _saveCV() async {
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
  }*/

  Future<void> _saveOrUpdateCV() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CV', style: pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 16),
                  pw.Text('Name: ${widget.userData?['name']}',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Email: ${widget.userData?['email']}',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Phone: ${widget.userData?['number']}',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Location: ${widget.userData?['location']}',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Designation: ${widget.userData?['designation']}',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.SizedBox(height: 16),
                  pw.Text('Summary:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_summaryController.text,
                      style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),
                  pw.Text('Experience:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_experienceController.text,
                      style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),
                  pw.Text('Education:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_educationController.text,
                      style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),
                  pw.Text('Skills:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(_skillsController.text,
                      style: pw.TextStyle(fontSize: 16)),
                ],
              );
            },
          ),
        );

        final output = await getTemporaryDirectory();
        final file = File('${output.path}/cv.pdf');
        await file.writeAsBytes(await pdf.save());

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${widget.userId}/cv.pdf');

        if (_cvExists) {
          await storageRef.putFile(
              file, SettableMetadata(contentType: 'application/pdf'));
        } else {
          await storageRef.putFile(
              file, SettableMetadata(contentType: 'application/pdf'));
        }

        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({'cv_pdf_url': downloadUrl});

        setState(() {
          _cvExists = true;
          _cvDownloadUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_cvExists
                  ? 'CV updated successfully'
                  : 'CV saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to save/update CV. Please try again later.')),
        );
      }
    }
  }

  Future<void> _downloadCV() async {
    if (_cvDownloadUrl != null) {
      final url = _cvDownloadUrl!;
      final fileName = 'cv.pdf';

      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);

      final dir = await getExternalStorageDirectory();
      // File file = File('${dir.path}/$fileName');
      File file = File('${dir!.path}/$fileName');
      print("The path is $file");
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CV downloaded successfully'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () /*async*/ {
              OpenFile.open(file.path);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clicked')),
              );
              // try {
              //   await OpenFile.open(file.path);
              // } catch (e) {
              //   print('Error opening file: $e');
              // }
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CV download URL not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create CV'),
        actions: [
          Visibility(
            visible: _cvExists,
            child: IconButton(
              onPressed: () {
                _downloadCV();
              },
              icon: Icon(Icons.download_rounded),
            ),
          ),
        ],
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
                    onPressed: /*_saveCV*/ _saveOrUpdateCV,
                    child: Text(/*'Save CV'*/
                        _cvExists ? 'Update CV' : 'Save CV'),
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
