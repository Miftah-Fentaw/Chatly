import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/screens/Notifications_Screen.dart';
import 'package:chatapp/screens/post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/chat_list_screen.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

final GlobalKey<_MainNavScreenState> mainNavKey = GlobalKey<_MainNavScreenState>();

class MainNavScreen extends StatefulWidget {
  MainNavScreen({Key? key, this.initialIndex = 0}) : super(key: key ?? mainNavKey);

  final int initialIndex;

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  final List<Widget> _pages =  [
    HomeScreen(),
    ChatListScreen(),
    PostScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    if (!mounted) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
     bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.pinned,
        snakeShape: SnakeShape.indicator,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        snakeViewColor: Theme.of(context).textTheme.bodySmall?.color,
        selectedItemColor:  Theme.of(context).textTheme.bodySmall?.color,
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
