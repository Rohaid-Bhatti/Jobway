import 'package:flutter/material.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final Map<String, String> applicant;

  const ApplicantDetailScreen({super.key, required this.applicant});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final applicant = widget.applicant;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    "https://cdn.pixabay.com/photo/2017/06/09/07/37/notebook-2386034_960_720.jpg"),
              ),
            ),
            SizedBox(height: 16),
            Text(
              applicant['name']!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              applicant['position']!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow(Icons.email, 'Email', applicant['email']!),
            SizedBox(height: 16),
            _buildDetailRow(Icons.phone, 'Phone', applicant['phone']!),
            SizedBox(height: 16),
            _buildDetailRow(Icons.description, 'Resume', applicant['resume']!),
            SizedBox(height: 16),
            _buildDetailRow(Icons.design_services, 'Type', applicant['type']!),
            SizedBox(height: 16),
            Text(
              'Status: ${applicant['status']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(applicant['status']!),
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle accept logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text('Accept', style: TextStyle(color: Colors.black),),
                  ),
                ),
                SizedBox(width: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle decline logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text('Decline', style: TextStyle(color: Colors.white),),
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
      case 'Pending':
        return Colors.orange;
      case 'Interviewed':
        return Colors.blue;
      case 'Hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
