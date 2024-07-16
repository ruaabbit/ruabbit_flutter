import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';

import 'package:ruabbit_flutter/model/user_profile.dart';
import 'package:ruabbit_flutter/page/navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDisplayMode.setHighRefreshRate();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProfile()),
        ChangeNotifierProvider(create: (context) => WaterFreeProfile())
      ],
      child: MaterialApp(
        home: const NavigationPage(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          textTheme: GoogleFonts.playballTextTheme(),
        ),
      ),
    );
  }
}
