import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/providerScreen/PDFViewerScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot applicant;

  const ApplicantDetailScreen({super.key, required this.applicant});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.applicant['status']!;
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('job_applied')
          .doc(widget.applicant['document_id'])
          .update({'status': newStatus});
      setState(() {
        // widget.applicant.reference.update({'status': newStatus});
        currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status. Please try again.')),
      );
    }
  }

  Future<void> _callPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: widget.applicant['user_number'],
    );

    if (await canLaunch(phoneLaunchUri.toString())) {
      await launch(phoneLaunchUri.toString());
    } else {
      throw 'Could not launch phone dialer';
    }
  }

  // for launching messages app
  void _openMessageApp() async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: widget.applicant['user_number'], // Replace with the desired number
    );

    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch messaging app';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? pictureUrl = widget.applicant['user_picture'];
    final bool hasPicture = pictureUrl != null && pictureUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _openMessageApp();
              },
              icon: Icon(Icons.message_outlined))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: hasPicture ? NetworkImage(pictureUrl) : null,
                child:
                    !hasPicture ? Image.asset('assets/icons/user.png') : null,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.applicant['user_name']!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.applicant['user_designation']!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow(
                Icons.email, 'Email', widget.applicant['user_email']!),
            SizedBox(height: 16),
            GestureDetector(
                onTap: () {
                  _callPhone();
                },
                child: _buildDetailRow(
                    Icons.phone, 'Phone', widget.applicant['user_number']!)),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PDFViewerScreen(pdfUrl: widget.applicant['user_cv']),
                  ),
                );
              },
              child: _buildDetailRow(
                  Icons.description, 'Resume', "Link to Resume"),
            ),
            SizedBox(height: 16),
            _buildDetailRow(
                Icons.design_services, 'Type', widget.applicant['job_type']!),
            SizedBox(height: 16),
            Text(
              'Status: $currentStatus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(currentStatus),
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentStatus != 'Rejected' &&
                    currentStatus != 'Hired') ...[
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentStatus == 'Processing') {
                          _updateStatus('Waiting for Interview');
                        } else if (currentStatus == 'Waiting for Interview') {
                          _updateStatus('Hired');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        currentStatus == 'Processing' ? 'Proceed' : 'Hired',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
                Center(
                  child: ElevatedButton(
                    onPressed: currentStatus == 'Hired'
                        ? null
                        : () {
                            _updateStatus('Rejected');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child:
                        Text('Reject', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
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
