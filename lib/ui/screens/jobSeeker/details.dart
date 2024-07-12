import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/payment_screen.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot job;

  const DetailsScreen({super.key, required this.job});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isJobSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkIfJobIsSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkIfJobIsSaved() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final savedJob = await FirebaseFirestore.instance
          .collection('job_saved')
          .where('user_id', isEqualTo: user.uid)
          .where('job_id', isEqualTo: widget.job['documentId'])
          .get();

      if (savedJob.docs.isNotEmpty) {
        setState(() {
          _isJobSaved = true;
        });
      }
    }
  }

  void _navigateToPaymentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(job: widget.job),
      ),
    );
  }

  Future<void> _toggleSaveJob() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final savedJobQuery = await FirebaseFirestore.instance
          .collection('job_saved')
          .where('user_id', isEqualTo: user.uid)
          .where('job_id', isEqualTo: widget.job['documentId'])
          .get();

      if (savedJobQuery.docs.isNotEmpty) {
        // Job is already saved, so remove it
        for (var doc in savedJobQuery.docs) {
          await FirebaseFirestore.instance
              .collection('job_saved')
              .doc(doc.id)
              .delete();
        }
        setState(() {
          _isJobSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job removed from saved list.')),
        );
      } else {
        // Create a new document reference
        DocumentReference savedDocRef =
            FirebaseFirestore.instance.collection('job_saved').doc();
        String docId = savedDocRef.id;

        // Job is not saved, so save it
        await savedDocRef.set({
          'document_id': docId,
          'job_id': widget.job['documentId'],
          'user_id': user.uid,
          'provider_id': widget.job['uid'],
          'saved_at': Timestamp.now(),
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
        });
        setState(() {
          _isJobSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job saved successfully.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in for this.')),
      );
    }
  }

  void _shareJob() {
    final jobDetails = '''
    Job Title: ${widget.job['title']}
    Description: ${widget.job['description']}
    ''';
    Share.share(jobDetails);
  }

  @override
  Widget build(BuildContext context) {
    final String? pictureUrl = widget.job['picture'];
    final bool hasPicture = pictureUrl != null && pictureUrl.isNotEmpty;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 2,
              child: hasPicture
                  ? Image.network(
                      pictureUrl,
                      fit: BoxFit.cover,
                      color: Colors.black38,
                      colorBlendMode: BlendMode.darken,
                    )
                  : Image.asset(
                      'assets/icons/company.png',
                      fit: BoxFit.cover,
                      color: Colors.black38,
                      colorBlendMode: BlendMode.darken,
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      _isJobSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _toggleSaveJob();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _shareJob();
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: MediaQuery.of(context).size.height / 3.5 - 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Job Details'),
                        Tab(text: 'Company Info'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildJobDetails(context),
                          _buildCompanyInfo(context),
                        ],
                      ),
                    ),
                    _buildApplyButton(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              widget.job['title'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 20,
              ),
              Text(
                widget.job['location'],
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 15.0),
          Text(
            "Job Description",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            widget.job['description'],
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.apply(color: Colors.grey),
          ),
          SizedBox(height: 15.0),
          Text(
            "Responsibility",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            widget.job['responsibility'],
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.apply(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Overview",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            widget.job['about'],
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.apply(color: Colors.grey),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Email",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            widget.job['email'],
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.apply(color: Colors.grey),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Number",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            widget.job['number'],
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.apply(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: ElevatedButton(
        child: Text(
          "Apply Now",
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.apply(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        onPressed: () {
          /*_applyForJob()*/_navigateToPaymentScreen();
        },
      ),
    );
  }
}
