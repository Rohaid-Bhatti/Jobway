import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  FAQScreen({super.key});

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I apply for a job?',
      'answer': 'To apply for a job, navigate to the job details page and click on the "Apply Now" button. Make sure you are logged in before applying.',
    },
    {
      'question': 'Can I save jobs to apply later?',
      'answer': 'Yes, you can save jobs by clicking the bookmark icon on the job details page. You can view saved jobs in the Saved Jobs section.',
    },
    {
      'question': 'How do I check the status of my job applications?',
      'answer': 'You can check the status of your job applications in the Applied Jobs section. The status will be displayed with color coding to indicate the progress.',
    },
    {
      'question': 'What should I do if I face issues with the app?',
      'answer': 'If you encounter any issues with the app, please contact our support team at support@jobportal.com. We are here to help!',
    },
    {
      'question': 'Can I cancel a job application?',
      'answer': 'Yes, you can cancel a job application from the job details page in the Applied Jobs section by clicking the "Cancel Application" button.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('FAQ')),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: ExpansionTile(
              title: Text(
                faqs[index]['question']!,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    faqs[index]['answer']!,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
