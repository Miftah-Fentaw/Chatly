import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/screens/chat_list_screen.dart';
import 'package:chatapp/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    return const ChatListScreen();
  }
}