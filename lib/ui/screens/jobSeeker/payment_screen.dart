import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PaymentScreen extends StatefulWidget {
  final QueryDocumentSnapshot job;

  const PaymentScreen({Key? key, required this.job}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  XFile? _receiptImage;
  bool _isLoading = false;

  Future<void> _applyForJob() async {
    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a receipt.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        // Get user details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        String userCV = userData['cv_pdf_url'] ?? '';
        String userDesignation = userData['designation'] ?? '';

        // Check if the user has completed their CV
        if (userCV.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please complete your CV before applying.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Check if the user's designation matches the job category
        if (userDesignation != widget.job['category']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Apply in the relevant field.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Upload the receipt to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final receiptRef = storageRef
            .child('receipts/${DateTime.now().millisecondsSinceEpoch}.png');
        await receiptRef.putFile(File(_receiptImage!.path));
        final receiptUrl = await receiptRef.getDownloadURL();

        String userEmail = userData['email'] ?? '';
        String userName = userData['name'] ?? '';
        String userPicture = userData['picture'] ?? '';
        String userNumber = userData['number'] ?? '';

        // Create a new document reference
        DocumentReference appliedDocRef =
            FirebaseFirestore.instance.collection('job_applied').doc();
        String docId = appliedDocRef.id;

        await appliedDocRef.set({
          'document_id': docId,
          'job_id': widget.job['documentId'],
          'user_id': user.uid,
          'user_email': userEmail,
          'user_name': userName,
          'user_cv': userCV,
          'user_picture': userPicture,
          'user_designation': userDesignation,
          'user_number': userNumber,
          'provider_id': widget.job['uid'],
          'applied_at': Timestamp.now(),
          'job_title': widget.job['title'],
          'job_description': widget.job['description'],
          'job_responsibility': widget.job['responsibility'],
          'job_location': widget.job['location'],
          'job_category': widget.job['category'],
          'job_type': widget.job['type'],
          'job_salary': widget.job['salary'],
          'company_about': widget.job['about'],
          'company_picture': widget.job['picture'],
          'company_number': widget.job['number'],
          'company_email': widget.job['email'],
          'receipt_url': receiptUrl,
          'status': 'Processing',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully Applied!')),
        );

        Navigator.pop(context); // Navigate back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to apply.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _receiptImage = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Account Number:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1234567890', // Replace with actual account number
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Upload Receipt:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: DottedBorder(
                color: Colors.blue,
                strokeWidth: 2,
                dashPattern: [6, 3],
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: Center(
                    child: _receiptImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 40, color: Colors.blue),
                        SizedBox(height: 8),
                        Center(child: Text('You can select a file')),
                      ],
                    )
                        : Image.file(File(_receiptImage!.path)),
                  ),
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _applyForJob,
                child: Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
