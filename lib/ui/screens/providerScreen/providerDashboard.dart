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
  var jobsPosted = 0;
  final int totalApplicants = 10; // Example data
  final List<Map<String, String>> applicants = [
    {
      'name': 'John Doe',
      'position': 'Flutter Developer',
      'status': 'Pending',
      'email': 'john.doe@example.com',
      'phone': '123-456-7890',
      'resume': 'Link to Resume',
      'type': 'Full Time'
    },
    {
      'name': 'Jane Smith',
      'position': 'UI/UX Designer',
      'status': 'Cancelled',
      'email': 'jane.smith@example.com',
      'phone': '098-765-4321',
      'resume': 'Link to Resume',
      'type': 'Full Time'
    },
    {
      'name': 'Michael Johnson',
      'position': 'Project Manager',
      'status': 'Hired',
      'email': 'michael.johnson@example.com',
      'phone': '111-222-3333',
      'resume': 'Link to Resume',
      'type': 'Full Time'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Call a function to fetch the count of jobs posted by the current user
    fetchJobsPostedByCurrentUser();
  }

  void fetchJobsPostedByCurrentUser() async {
    // Get the UID of the current user
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

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
      body: Padding(
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
              child: ListView.builder(
                itemCount: applicants.length,
                itemBuilder: (context, index) {
                  final applicant = applicants[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ApplicantDetailScreen(
                                    applicant: applicant,
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
                          backgroundImage: NetworkImage(
                              "https://cdn.pixabay.com/photo/2017/06/09/07/37/notebook-2386034_960_720.jpg"),
                        ),
                        title: Text(applicant['name']!),
                        subtitle: Text(applicant['position']!),
                        trailing: Text(
                          applicant['status']!,
                          style: TextStyle(
                            color: _getStatusColor(applicant['status']!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      /*case 'Interviewed':
        return Colors.blue;*/
      case 'Hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
