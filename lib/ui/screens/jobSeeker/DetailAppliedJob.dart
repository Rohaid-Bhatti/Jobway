import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailAppliedJob extends StatelessWidget {
  final QueryDocumentSnapshot job;

  const DetailAppliedJob({super.key, required this.job});

  Future<void> _cancelApplication(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_applied')
          .doc(job['document_id'])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job application cancelled successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final String? pictureUrl = job['company_picture'];
    final bool hasPicture = pictureUrl != null && pictureUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Details',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: hasPicture ? NetworkImage(pictureUrl) : null,
                  child: !hasPicture
                      ? Image.asset('assets/icons/company.png')
                      : null,
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Text(
                  job['job_title'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(height: 8.0),
              Center(
                child: Text(
                  job['job_location'],
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Job Description",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        job['job_description'],
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        "Responsibilities",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        job['job_responsibility'],
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Company Information",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Overview",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        job['company_about'],
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Email",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        job['company_email'],
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Number",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        job['company_number'],
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.apply(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        job['status'],
                        style: TextStyle(
                          color: _getStatusColor(job['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  child: Text(
                    "Cancel Application",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.apply(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _cancelApplication(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
