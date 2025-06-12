import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_with_firebase/providers/auth_provider.dart';
import 'package:todo_app_with_firebase/providers/todo_provider.dart';
import 'package:todo_app_with_firebase/screens/auth_screen.dart';
import 'package:todo_app_with_firebase/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider())
      ],
      child: MaterialApp(
        title: 'Modern Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    print('AuthWrapper: authProvider.user = ${authProvider.user}');

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.user != null) {
          // User is logged in
          todoProvider.fetchTodos(authProvider.user!.uid);
          return HomeScreen();
        } else {
          // User is logged out
          todoProvider.clearTodos();
          return AuthScreen();
        }
      },
    );
  }
}