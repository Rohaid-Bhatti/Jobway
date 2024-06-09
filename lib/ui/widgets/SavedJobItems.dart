import 'package:flutter/material.dart';

class SavedJobItems extends StatelessWidget {
  const SavedJobItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                  "https://cdn.pixabay.com/photo/2015/01/08/18/25/desk-593327_1280.jpg"),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Flutter Developer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Development',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.black45,
                        size: 18,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Lahore',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        color: Colors.black45,
                        size: 18,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Full-time',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.bookmark_rounded),
              onPressed: () {
                // Handle bookmark action
              },
            ),
          ],
        ),
      ),
    );
  }
}
