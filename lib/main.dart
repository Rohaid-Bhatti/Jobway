import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/models/bottomsheet.dart';
import 'package:flutter_job_portal/ui/widgets/AuthCheck.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAOwku4isph17vlQeC1tAGgMgKL9mQN94I",
            appId: "1:30287351300:android:a4dc2b8e01068b252c2f51",
            messagingSenderId: "30287351300",
            projectId: "job-portal-41b17",
            storageBucket: "job-portal-41b17.appspot.com",
          ),
        )
      : await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyBottomSheetModel>(
      create: (_) => MyBottomSheetModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'OpenSans',
        ),
        home: AuthCheck(),
      ),
    );
  }
}
