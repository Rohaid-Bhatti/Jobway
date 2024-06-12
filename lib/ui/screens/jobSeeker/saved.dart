import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/global.dart';
import 'package:flutter_job_portal/ui/widgets/SavedJobItems.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  Future<void> _unsaveJob(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('job_saved').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job removed from saved list.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Saved',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('job_saved')
              .where('user_id',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No jobs saved yet.'));
            }

            final saved = snapshot.data!.docs;
            return ListView.builder(
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final save = saved[index];
                return SavedJobItems(
                  pic: save['company_picture'],
                  title: save['job_title'],
                  location: save['job_location'],
                  category: save['job_category'],
                  type: save['job_type'],
                  isSaved: true,
                  onSave: () {
                    _unsaveJob(save['document_id']);
                  },
                );
              },
            );
          }),
    );
  }
}
