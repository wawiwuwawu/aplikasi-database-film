import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weebase/screen/login_screen.dart';
import 'package:weebase/screen/splash_screen.dart';
import 'package:weebase/service/preferences_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await PreferencesService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wawunime',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue
        ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        // ...tambahkan route lain jika perlu
      },
    );
  }
}
