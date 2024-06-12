import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/global.dart';
import 'package:flutter_job_portal/models/bottomsheet.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/details.dart';
import 'package:flutter_job_portal/ui/widgets/jobcontainer.dart';
import 'package:flutter_job_portal/ui/widgets/mybottomsheet.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        _userData = userData.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfff0f0f6),
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.0,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Welcome ${_userData?['name']}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        CircleAvatar(
                          backgroundImage: _userData?['picture'] != null &&
                                  _userData!['picture'].isNotEmpty
                              ? NetworkImage(_userData!['picture'])
                              : AssetImage('assets/icons/user.png')
                                  as ImageProvider,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 51,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: "Search",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide.none),
                                fillColor: Color(0xffe6e6ec),
                                filled: true,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffe6e6ec),
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.tune),
                              onPressed: () {
                                Provider.of<MyBottomSheetModel>(context,
                                        listen: false)
                                    .changeState();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('job_posted')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No jobs posted yet.'));
                          }

                          final jobs = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: jobs.length,
                            itemBuilder: (ctx, i) {
                              final job = jobs[i];
                              return JobContainer(
                                description: job['description'],
                                iconUrl: job['picture'] ??
                                    'https://cdn.pixabay.com/photo/2015/01/08/18/26/write-593333_960_720.jpg',
                                location: job['location'],
                                salary: job['salary'],
                                title: job['title'],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => DetailsScreen(
                                      job: job,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Provider.of<MyBottomSheetModel>(context).visible
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: MyBottomSheet(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
