import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hive_model/chat_item.dart';
import 'hive_model/message_item.dart';
import 'hive_model/message_role.dart';
import 'screens/home.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatItemAdapter());
  Hive.registerAdapter(MessageItemAdapter());
  Hive.registerAdapter(MessageRoleAdapter());
  await Hive.openBox('chats');
  await Hive.openBox('messages');

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool isSignedUp =
      prefs.getString('email') != null && prefs.getString('password') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn, isSignedUp: isSignedUp));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isSignedUp;

  const MyApp({super.key, required this.isLoggedIn, required this.isSignedUp});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      initialRoute: isSignedUp ? (isLoggedIn ? '/home' : '/login') : '/signup',
      routes: {
        '/home': (context) => const Home(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
