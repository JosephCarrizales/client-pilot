import 'package:client_pilot/pages/contacts_page.dart';
import 'package:client_pilot/pages/home_dashboard_page.dart';
import 'package:client_pilot/pages/notifications_page.dart';
import 'package:client_pilot/pages/settings_page.dart';
import 'package:client_pilot/pages/tasks_page.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  //static const TextStyle optionStyle = TextStyle(
    //fontSize: 30, fontWeight: FontWeight.bold);

  final List<Widget> widgetOptions = <Widget>[
    HomeDashboardPage(),
    ContactsPage(),
    TasksPage(),
    NotificationsPage(),
    SettingsPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 35),
      //body: Center(
       // child:
       body: widgetOptions.elementAt(selectedIndex),
      //),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            backgroundColor: Colors.blueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page_outlined),
            label: 'Contacts',
            backgroundColor: Colors.blueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'Tasks',
            backgroundColor: Colors.blueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add_outlined),
            label: 'Notifications',
            backgroundColor: Colors.blueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.blueAccent,
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}