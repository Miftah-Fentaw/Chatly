import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/providers/theme_provider.dart';
import 'package:chatapp/screens/login_screen.dart';
import 'package:chatapp/screens/signup_screen.dart';
import 'package:chatapp/screens/forgot_password_screen.dart';
import 'package:chatapp/screens/reset_sent_screen.dart';
import 'package:chatapp/screens/chat_detail_screen.dart';
import 'package:chatapp/screens/main_nav_screen.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/theme.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // While auth status is being determined, IT show a splash/loading screen
        if (auth.isLoading) {
          return MaterialApp(
            title: 'ChatApp',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: context.watch<ThemeProvider>().themeMode,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // This rebuilds the entire router whenever currentUser changes
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: auth.currentUser != null ? '/home' : '/login',
          redirect: (context, state) {
            final loggedIn = auth.currentUser != null;
            final isAuthScreen = ['/login', '/signup', '/forgot-password']
                .contains(state.matchedLocation);
            if (loggedIn && isAuthScreen) return '/home';
            if (!loggedIn && !isAuthScreen) return '/login';
            return null;
          },
          routes: [
            GoRoute(
              path: '/login',
              name: 'login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/signup',
              name: 'signup',
              builder: (context, state) => const SignupScreen(),
            ),
            GoRoute(
              path: '/forgot-password',
              name: 'forgot-password',
              builder: (context, state) => const ForgotPasswordScreen(),
            ),
            GoRoute(
              path: '/reset-sent',
              name: 'reset-sent',
              builder: (context, state) {
                return const ResetSentScreen();
              },
            ),
            GoRoute(
              path: '/chats',
              name: 'chats',
              builder: (context, state) => MainNavScreen(),
            ),
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => MainNavScreen(initialIndex: 0),
            ),
            GoRoute(
              path: '/chat/:chatId',
              name: 'chat-detail',
              builder: (context, state) {
                final chatId = state.pathParameters['chatId']!;
                final otherUser = state.extra as UserModel;
                return ChatDetailScreen(chatId: chatId, otherUser: otherUser);
              },
            ),
            GoRoute(
              path: '/notifications',
              name: 'notifications',
              builder: (context, state) => MainNavScreen(),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => MainNavScreen(),
            ),
            GoRoute(
              path: '/post',
              name: 'post',
              builder: (context, state) => MainNavScreen(initialIndex: 2),
            ),
          ],
        );

        return MaterialApp.router(
          title: 'ChatApp',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: context.watch<ThemeProvider>().themeMode,
          routerConfig: router,
        );
      },
    );
  }
}