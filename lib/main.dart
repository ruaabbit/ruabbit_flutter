import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';
import 'package:ruabbit_flutter/model/user_profile.dart';
import 'package:ruabbit_flutter/page/navigation_page.dart';
import 'package:ruabbit_flutter/util/persist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDisplayMode.setHighRefreshRate();

  final userProfile = await getUserProfileFromPrefs();
  final waterFreeProfile = await getWaterFreeProfileFromPrefs();
  runApp(MyApp(userProfile: userProfile, waterFreeProfile: waterFreeProfile));
}

class MyApp extends StatelessWidget {
  final UserProfile userProfile;
  final WaterFreeProfile waterFreeProfile;

  const MyApp(
      {super.key, required this.userProfile, required this.waterFreeProfile});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userProfile),
        ChangeNotifierProvider(create: (context) => waterFreeProfile),
      ],
      child: MaterialApp(
        home: const NavigationPage(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          // textTheme: GoogleFonts.playballTextTheme(),
        ),
      ),
    );
  }
}
