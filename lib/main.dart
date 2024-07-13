import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/model/UserProfile.dart';
import 'package:ruabbit_flutter/page/NavigationPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfile(),
      child: MaterialApp(
        home: const NavigationPage(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        ),
      ),
    );
  }
}
