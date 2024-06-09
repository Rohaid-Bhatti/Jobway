import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/dashboardScreen.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/signInScreen.dart';
import 'package:flutter_job_portal/ui/screens/providerScreen/providerDashboard.dart';

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          User? user = snapshot.data;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData) {
                String userType = userSnapshot.data!['type'];
                if (userType == "Employee") {
                  return DashboardScreen();
                } else {
                  return ProviderDashboard();
                }
              }
              return SignInScreen();
            },
          );
        }
        return SignInScreen();
      },
    );
  }
}