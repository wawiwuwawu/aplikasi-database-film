import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screen/login_screen.dart';
import 'package:flutter_application_1/screen/main_screen.dart';
import 'package:flutter_application_1/screen/splash_screen.dart';
import 'package:flutter_application_1/service/preferences_service.dart';
import 'screen/movie_list.dart';

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
