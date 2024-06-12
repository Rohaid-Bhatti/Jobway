import 'package:flutter/material.dart';

class SavedJobItems extends StatefulWidget {
  String pic, title, location, category, type;
  bool isSaved;
  final Function() onSave;

  SavedJobItems({
    super.key,
    required this.pic,
    required this.title,
    required this.location,
    required this.category,
    required this.type,
    required this.isSaved,
    required this.onSave,
  });

  @override
  State<SavedJobItems> createState() => _SavedJobItemsState();
}

class _SavedJobItemsState extends State<SavedJobItems> {
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
              backgroundImage: NetworkImage(widget.pic),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.category,
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
                        widget.location,
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
                        widget.type,
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
              icon: widget.isSaved
                  ? Icon(Icons.bookmark_rounded)
                  : Icon(Icons.bookmark_outline_rounded),
              onPressed: widget.onSave,
            ),
          ],
        ),
      ),
    );
  }
}
