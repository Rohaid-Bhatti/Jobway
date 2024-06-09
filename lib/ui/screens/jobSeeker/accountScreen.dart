import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) updateUserData;

  const AccountScreen(
      {Key? key,
      required this.user,
      required this.userData,
      required this.updateUserData})
      : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  XFile? _profileImageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _nameController.text = widget.userData!['name'] ?? '';
      _phoneController.text = widget.userData!['number'] ?? '';
      _aboutController.text = widget.userData!['about'] ?? '';
      _addressController.text = widget.userData!['location'] ?? '';
      _skillController.text = widget.userData!['skills'] ?? '';
      _jobController.text = widget.userData!['designation'] ?? '';
      _profileImageUrl = widget.userData!['picture'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImageFile = image; // Store the selected image file
          _profileImageUrl = null; // Clear existing URL if any
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String> _uploadImageToFirebase(XFile image) async {
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child(widget.user!.uid);
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> _saveProfile() async {
    try {
      String downloadUrl = _profileImageUrl ?? ''; // Use existing URL or empty string if no URL
      if (_profileImageFile != null) {
        downloadUrl = await _uploadImageToFirebase(_profileImageFile!);
      }
      final Map<String, dynamic> newData = {
        'name': _nameController.text,
        'number': _phoneController.text,
        'location': _addressController.text,
        'skills': _skillController.text,
        'designation': _jobController.text,
        'about': _aboutController.text,
        'picture': downloadUrl,
      };
      widget.updateUserData(newData);
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Account Setting",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImageFile != null
                                ? FileImage(File(_profileImageFile!.path))
                                : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                ? NetworkImage(_profileImageUrl!)
                                : AssetImage('assets/icons/user.png') as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Address',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _skillController,
                decoration: InputDecoration(
                  hintText: 'Skills',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _jobController,
                decoration: InputDecoration(
                  hintText: 'Designation',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _aboutController,
                decoration: InputDecoration(
                  hintText: 'About Me',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                maxLines: 5,
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Save the profile information
                    _saveProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
