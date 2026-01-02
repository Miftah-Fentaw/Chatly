import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/screens/Notifications_Screen.dart';
import 'package:chatapp/screens/post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/chat_list_screen.dart';
import 'package:chatapp/screens/profile_screen.dart';

final GlobalKey<_MainNavScreenState> mainNavKey =
    GlobalKey<_MainNavScreenState>();

class MainNavScreen extends StatefulWidget {
  MainNavScreen({Key? key, this.initialIndex = 0})
      : super(key: key ?? mainNavKey);

  final int initialIndex;

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  final List<Widget> _pages = [
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
      // Extend body behind navbar for transparency effects if desired,
      // but standard Material 3 usually keeps them separate or uses translucent scrims.
      // For now, standard layout is safer to avoid content overlap.
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(fontWeight: FontWeight.w600, fontSize: 12);
            }
            return const TextStyle(fontWeight: FontWeight.normal, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          // Modern styling from Theme is applied automatically,
          // but we can override specific behaviors here.
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(CupertinoIcons.home),
              selectedIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.chat_bubble),
              selectedIcon: Icon(CupertinoIcons.chat_bubble_fill),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.plus_app), // Distinct add icon
              selectedIcon: Icon(CupertinoIcons.plus_app_fill),
              label: 'Post',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.bell),
              selectedIcon: Icon(CupertinoIcons.bell_fill),
              label:
                  'Activity', // "Activity" is often more modern than "Notification"
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.person),
              selectedIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
