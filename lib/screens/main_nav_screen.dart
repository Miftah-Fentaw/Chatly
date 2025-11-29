import 'package:chatapp/screens/Home_Screen.dart';
import 'package:chatapp/screens/Notifications_Screen.dart';
import 'package:chatapp/screens/post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/chat_list_screen.dart';
import 'package:chatapp/screens/settings_screen.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    ChatListScreen(),
    PostScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
     bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.indicator,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        snakeViewColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).primaryColorLight,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        height: MediaQuery.of(context).size.height * 0.08,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble), label: 'messages'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bell), label: 'notification'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
