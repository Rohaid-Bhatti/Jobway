import 'package:flutter/material.dart';
import 'package:flutter_job_portal/global.dart';
import 'package:flutter_job_portal/ui/widgets/SavedJobItems.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
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
      body: ListView.builder(
        itemCount: jobList.length,
        itemBuilder: (ctx, i) {
          return SavedJobItems();
        },
      ),
    );
  }
}
