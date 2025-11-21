import 'package:flutter/material.dart';
import 'package:student_attendance_app/screens/home_screen.dart';
import 'package:student_attendance_app/screens/profile_screen.dart';
import 'package:student_attendance_app/screens/timetable_screen.dart'; // Timetable screen එක import කරගන්නවා

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Bottom Navigation Bar එකේ දැනට select වෙලා තියෙන item එකේ index එක
  int _selectedIndex = 0;

  // Bottom Navigation Bar එකේ හැම item එකකටම අදාළ screen එක
  // List එකේ පිළිවෙල, BottomNavigationBarItem වල පිළිවෙලට සමාන වෙන්න ඕන.
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Index 0: Home
    const MyTimetableScreen(), // Index 1: Timetable (Menu වෙනුවට)
    const ProfileScreen(), // Index 2: Profile
  ];

  // Navigation Bar එකේ item එකක් tap කරාම මේ function එක call වෙනවා
  void _onItemTapped(int index) {
    // setState එකෙන් UI එක update කරලා, අලුත් screen එක පෙන්නනවා
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body එක විදියට, select වෙලා තියෙන index එකට අදාළ screen එක පෙන්නනවා
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // Bottom Navigation Bar එක
      bottomNavigationBar: BottomNavigationBar(
        // Items (Buttons) ටික
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Select වුණාම පෙන්නන icon එක
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Timetable', // 'Menu' වෙනුවට 'Timetable'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // දැනට select වෙලා තියෙන item එක
        selectedItemColor: Colors.blue, // Select වුණු item එකේ color එක
        unselectedItemColor: Colors.grey, // Select නැති items වල color එක
        onTap: _onItemTapped, // Item එකක් tap කරාම call වෙන function එක
        showUnselectedLabels: false, // Select නැති item වල label එක hide කරනවා
        type: BottomNavigationBarType
            .fixed, // fixed type එකෙන් animation එකක් නැතුව items ටික පෙන්නනවා
      ),
    );
  }
}
