import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/DetailAppliedJob.dart';

class AppliedJobScreen extends StatefulWidget {
  const AppliedJobScreen({super.key});

  @override
  State<AppliedJobScreen> createState() => _AppliedJobScreenState();
}

class _AppliedJobScreenState extends State<AppliedJobScreen> {
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.blue;
      case 'Waiting for Interview':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      case 'Hired':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Applied Jobs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('job_applied')
            .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No jobs applied yet.'));
          }

          final appliedJobs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: appliedJobs.length,
            itemBuilder: (context, index) {
              final job = appliedJobs[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: job['company_picture'].isNotEmpty
                        ? NetworkImage(job['company_picture'])
                        : null,
                    child: job['company_picture'].isEmpty
                        ? Image.asset('assets/icons/company.png')
                        : null,
                    onBackgroundImageError: (_, __) {
                      setState(() {}); // Force widget to rebuild
                    },
                  ),
                  title: Text(
                    job['job_title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${job['job_location']} • ${job['job_category']} • ${job['job_type']}'),
                      SizedBox(height: 4),
                      Text(
                        job['status'],
                        style: TextStyle(
                          color: _getStatusColor(job['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Applied on ${job['applied_at'].toDate().toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailAppliedJob(job: job)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
