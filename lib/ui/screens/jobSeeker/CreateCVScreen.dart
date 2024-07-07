import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  bool _cvExists = false;
  String? _cvDownloadUrl;
  File? _imageFile; // To store selected image file

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

  /*Future<void> _saveOrUpdateCV() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              List<pw.Widget> cvContent = [
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
                pw.Text('Date of Birth: ${_dobController.text}',
                    style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 16),
                pw.Text('Summary:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_summaryController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                pw.Text('Experience:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_experienceController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text(
                  'Job: ${_jobTitleController.text} ,  Company: ${_companyNameController.text}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Education:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_educationController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                pw.Text('Skills:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_skillsController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                pw.Text('Languages:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_languageController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                pw.Text('Reference:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_referenceController.text,
                    style: pw.TextStyle(fontSize: 16)),
              ];

              // Add image if selected
              if (_imageFile != null) {
                cvContent.add(pw.SizedBox(height: 16));
                cvContent.add(pw.Image(
                  pw.MemoryImage(
                    _imageFile!.readAsBytesSync(),
                  ),
                ));
              }

              // Optional fields
              if (_linkedInController.text.isNotEmpty) {
                cvContent.add(pw.SizedBox(height: 16));
                cvContent.add(pw.Text('LinkedIn Profile:',
                    style: pw.TextStyle(fontSize: 18)));
                cvContent.add(pw.Text(_linkedInController.text,
                    style: pw.TextStyle(fontSize: 16)));
              }

              if (_portfolioController.text.isNotEmpty) {
                cvContent.add(pw.SizedBox(height: 16));
                cvContent.add(
                    pw.Text('Portfolio:', style: pw.TextStyle(fontSize: 18)));
                cvContent.add(pw.Text(_portfolioController.text,
                    style: pw.TextStyle(fontSize: 16)));
              }

              if (_certificateController.text.isNotEmpty) {
                cvContent.add(pw.SizedBox(height: 16));
                cvContent.add(pw.Text('Certificates:',
                    style: pw.TextStyle(fontSize: 18)));
                cvContent.add(pw.Text(_certificateController.text,
                    style: pw.TextStyle(fontSize: 16)));
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cvContent,
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
                : 'CV saved successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save/update CV. Please try again later.'),
          ),
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
              List<pw.Widget> cvContent = [
                pw.Text('CV', style: pw.TextStyle(fontSize: 24)),
              ];

              // Add image if selected
              if (_imageFile != null) {
                cvContent.add(pw.SizedBox(height: 16));
                cvContent.add(pw.Image(
                  pw.MemoryImage(
                    _imageFile!.readAsBytesSync(),
                  ),
                  height: 80,
                  width: 80
                ));
              }

              cvContent.addAll([
                pw.SizedBox(height: 12),
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
                pw.Text('Date of Birth: ${_dobController.text}',
                    style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 12),
                pw.Text('Summary:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_summaryController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text('Experience:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_experienceController.text,
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text(
                  'Job: ${_jobTitleController.text} ,  Company: ${_companyNameController.text}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Education:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_educationController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text('Skills:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_skillsController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text('Languages:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_languageController.text,
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text('Reference:', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_referenceController.text,
                    style: pw.TextStyle(fontSize: 16)),
              ]);

              // Optional fields
              if (_linkedInController.text.isNotEmpty) {
                cvContent.add(pw.SizedBox(height: 12));
                cvContent.add(pw.Text('LinkedIn Profile:',
                    style: pw.TextStyle(fontSize: 18)));
                cvContent.add(pw.Text(_linkedInController.text,
                    style: pw.TextStyle(fontSize: 12)));
              }

              if (_portfolioController.text.isNotEmpty) {
                cvContent.add(pw.SizedBox(height: 12));
                cvContent.add(
                    pw.Text('Portfolio:', style: pw.TextStyle(fontSize: 18)));
                cvContent.add(pw.Text(_portfolioController.text,
                    style: pw.TextStyle(fontSize: 12)));
              }

              if (_certificateController.text.isNotEmpty) {
                cvContent.add(pw.SizedBox(height: 12));
                cvContent.add(pw.Text('Certificates:',
                    style: pw.TextStyle(fontSize: 18)));
                cvContent.add(pw.Text(_certificateController.text,
                    style: pw.TextStyle(fontSize: 12)));
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: cvContent,
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
                : 'CV saved successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save/update CV. Please try again later.'),
          ),
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

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
                GestureDetector(
                  onTap: () {
                    _pickImageFromGallery();
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : AssetImage("assets/icons/user.png") as ImageProvider,
                  ),
                ),
                SizedBox(height: 16,),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _linkedInController,
                  decoration: InputDecoration(labelText: 'LinkedIn Profile (optional)'),
                  maxLines: 1,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _portfolioController,
                  decoration: InputDecoration(labelText: 'Portfolio (optional)'),
                  maxLines: 1,
                ),
                SizedBox(height: 16),
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
                  controller: _jobTitleController,
                  decoration: InputDecoration(labelText: 'Jobs Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your jobs title';
                    }
                    return null;
                  },
                  maxLines: 1,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(labelText: 'Company Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your company name';
                    }
                    return null;
                  },
                  maxLines: 1,
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
                  controller: _certificateController,
                  decoration: InputDecoration(labelText: 'Certificates (optional)'),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 16,
                ),
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _languageController,
                  decoration: InputDecoration(labelText: 'Languages'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the languages';
                    }
                    return null;
                  },
                  maxLines: 1,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(labelText: 'Reference'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your reference';
                    }
                    return null;
                  },
                  maxLines: 1,
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
