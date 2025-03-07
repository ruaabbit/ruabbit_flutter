import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';
import 'package:ruabbit_flutter/app/Order/model/phone_profile.dart';
import 'package:ruabbit_flutter/model/user_profile.dart';
import 'package:ruabbit_flutter/page/navigation_page.dart';
import 'package:ruabbit_flutter/util/persist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDisplayMode.setHighRefreshRate();

  final userProfile = await getUserProfileFromPrefs();
  final waterFreeProfile = await getWaterFreeProfileFromPrefs();
  final phoneProfile = await getPhoneProfileFromPrefs();
  runApp(MyApp(
    userProfile: userProfile,
    waterFreeProfile: waterFreeProfile,
    phoneProfile: phoneProfile,
  ));
}

class MyApp extends StatelessWidget {
  final UserProfile userProfile;
  final WaterFreeProfile waterFreeProfile;
  final PhoneProfile phoneProfile;

  const MyApp({
    super.key,
    required this.userProfile,
    required this.waterFreeProfile,
    required this.phoneProfile,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userProfile),
        ChangeNotifierProvider(create: (context) => waterFreeProfile),
        ChangeNotifierProvider(create: (context) => phoneProfile),
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
