import 'package:flutter/material.dart';

class MyBottomSheetModel extends ChangeNotifier {
  bool _visible = false;
  get visible => _visible;
  void changeState() {
    _visible = !_visible;
    notifyListeners();
  }

  List<String> selectedJobTypes = [];
  RangeValues selectedSalaryRange = RangeValues(0, 300000);

  void updateJobTypes(List<String> jobTypes) {
    selectedJobTypes = jobTypes;
    notifyListeners();
  }

  void updateSalaryRange(RangeValues rangeValues) {
    selectedSalaryRange = rangeValues;
    notifyListeners();
  }
}