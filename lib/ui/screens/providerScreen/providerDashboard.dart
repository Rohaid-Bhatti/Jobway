import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/providerScreen/applicantDetail.dart';
import 'package:flutter_job_portal/ui/screens/providerScreen/providerHome.dart';
import 'package:flutter_job_portal/ui/screens/providerScreen/providerProfile.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  var jobsPosted = 0;
  var totalApplicants = 0;

  @override
  void initState() {
    super.initState();
    fetchJobsPostedByCurrentUser();
    fetchTotalApplicantByCurrentUser();
  }

  Future<void> fetchJobsPostedByCurrentUser() async {
    // Query the "job_posted" collection to get the count of jobs posted by the current user
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('job_posted')
        .where('uid', isEqualTo: currentUserUid)
        .get();

    // Set the jobsPosted count to the number of documents retrieved
    setState(() {
      jobsPosted = snapshot.size;
    });
  }

  Future<void> fetchTotalApplicantByCurrentUser() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('job_applied')
        .where('provider_id', isEqualTo: currentUserUid)
        .get();

    setState(() {
      totalApplicants = snapshot.size;
    });
  }

  Future<void> _refreshData() async {
    await fetchJobsPostedByCurrentUser();
    await fetchTotalApplicantByCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to post a new job screen
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProviderProfile()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JobProviderHome()));
                      },
                      child: Container(
                        height: 150,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Jobs Posted',
                              maxLines: 1,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$jobsPosted',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Applicants',
                            maxLines: 1,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$totalApplicants',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Applicants',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('job_applied')
                        .where('provider_id',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No jobs applied yet.'));
                      }

                      final applicantJob = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: applicantJob.length,
                        itemBuilder: (context, index) {
                          final applicantJobs = applicantJob[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ApplicantDetailScreen(
                                            applicant: applicantJobs,
                                          )));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      applicantJobs['user_picture'].isNotEmpty
                                          ? NetworkImage(
                                              applicantJobs['user_picture'])
                                          : null,
                                  child: applicantJobs['user_picture'].isEmpty
                                      ? Image.asset('assets/icons/user.png')
                                      : null,
                                ),
                                title: Text(applicantJobs['user_name']!),
                                subtitle:
                                    Text(applicantJobs['user_designation']!),
                                trailing: Text(
                                  applicantJobs['status']!,
                                  style: TextStyle(
                                    color: _getStatusColor(
                                        applicantJobs['status']!),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
