import 'package:flutter/material.dart';
import 'package:flutter_job_portal/models/bottomsheet.dart';
import 'package:provider/provider.dart';

class MyBottomSheet extends StatefulWidget {
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class JobTypes {
  final String title;
  bool checked;

  JobTypes({required this.checked, required this.title});
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  List<JobTypes> jobTypes = [
    JobTypes(title: "Full-Time", checked: false),
    JobTypes(title: "Part-Time", checked: false),
    JobTypes(title: "Internship", checked: false),
  ];
  RangeValues _rangeValues = RangeValues(0, 300000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Salary Estimate",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          RangeSlider(
            min: 0,
            max: 300000,
            values: _rangeValues,
            onChanged: (rangeValue) {
              setState(() {
                _rangeValues = rangeValue;
              });
            },
            labels: RangeLabels(
                _rangeValues.start.toString(), _rangeValues.end.toString()),
          ),
          Text(
            "Job Type",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          GridView.count(
            shrinkWrap: true,
            childAspectRatio: 7,
            crossAxisCount: 1,
            children: List.generate(
              jobTypes.length,
                  (i) {
                return Row(
                  children: <Widget>[
                    Checkbox(
                      value: jobTypes[i].checked,
                      onChanged: (value) {
                        setState(() {
                          jobTypes[i].checked = value!;
                        });
                      },
                    ),
                    Text("${jobTypes[i].title}"),
                  ],
                );
              },
            ),
          ),
          Container(
            height: 40,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 25.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                "Submit",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.apply(color: Colors.white),
              ),
              onPressed: () {
                final selectedTypes = jobTypes
                    .where((type) => type.checked)
                    .map((type) => type.title)
                    .toList();
                Provider.of<MyBottomSheetModel>(context, listen: false)
                    .updateJobTypes(selectedTypes);
                Provider.of<MyBottomSheetModel>(context, listen: false)
                    .updateSalaryRange(_rangeValues);
                Provider.of<MyBottomSheetModel>(context, listen: false)
                    .changeState();
              },
            ),
          )
        ],
      ),
    );
  }
}
