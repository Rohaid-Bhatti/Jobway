import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/providerScreen/providerSignIn.dart';
import 'package:image_picker/image_picker.dart';

class ProviderProfile extends StatefulWidget {
  const ProviderProfile({super.key});

  @override
  State<ProviderProfile> createState() => _ProviderProfileState();
}

class _ProviderProfileState extends State<ProviderProfile> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? email;
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  XFile? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _user = user;
        _userData = userData.data() as Map<String, dynamic>?;
        if (_userData != null) {
          _nameController.text = _userData!['name'] ?? '';
          _phoneController.text = _userData!['number'] ?? '';
          email = _userData!['email'] ?? '';
          _descriptionController.text = _userData!['about'] ?? '';
          _locationController.text = _userData!['location'] ?? '';
          _profileImageUrl = _userData!['picture'] ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
                child: Text('Yes'),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProviderSignIn()),
                  );
                }),
          ],
        );
      },
    );
  }

  Future<void> _updateUserData(Map<String, dynamic> newData) async {
    try {
      await _firestore.collection('providers').doc(_user!.uid).update(newData);
      setState(() {
        _userData?.addAll(newData);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (error) {
      print('Error updating user data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update profile. Please try again later.')),
      );
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String downloadUrl = _profileImageUrl ??
            ''; // Use existing URL or empty string if no URL
        if (_profileImageFile != null) {
          downloadUrl = await _uploadImageToFirebase(_profileImageFile!);
        }
        final Map<String, dynamic> newData = {
          'name': _nameController.text,
          'number': _phoneController.text,
          'location': _locationController.text,
          'about': _descriptionController.text,
          'picture': downloadUrl,
        };
        _updateUserData(newData);
      } catch (e) {
        print('Error saving profile: $e');
      }
    }
  }

  Future<String> _uploadImageToFirebase(XFile image) async {
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('provider_profile_images')
          .child(_user!.uid);
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: Icon(Icons.logout_rounded))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageFile != null
                            ? FileImage(File(_profileImageFile!.path))
                            : (_profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty)
                            ? NetworkImage(_profileImageUrl!)
                            : AssetImage('assets/icons/user.png')
                        as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 6),
                    Center(
                        child: Text(email ?? '',
                            style: TextStyle(color: Colors.grey))),
                    SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        child: Text(
                          'Change Picture',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(_nameController, 'Name'),
                    SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Phone Number',
                        keyboardType: TextInputType.phone),
                    SizedBox(height: 16),
                    _buildTextField(_locationController, 'Location',
                        keyboardType: TextInputType.streetAddress),
                    SizedBox(height: 16),
                    _buildTextField(
                        _descriptionController, 'Description/About Me',
                        maxLines: 5),
                    SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          'Update Profile',
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

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
