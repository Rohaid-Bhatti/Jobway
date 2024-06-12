import 'package:flutter/material.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/AppliedJobScreen.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/home.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/profile.dart';
import 'package:flutter_job_portal/ui/screens/jobSeeker/saved.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SavedScreen(),
    AppliedJobScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Icon(Icons.home_rounded)
                : Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Icon(Icons.bookmark_rounded)
                : Icon(Icons.bookmark_border_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Icon(Icons.call_to_action_rounded)
                : Icon(Icons.call_to_action_outlined),
            label: 'Applied',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 3
                ? Icon(Icons.person_rounded)
                : Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
