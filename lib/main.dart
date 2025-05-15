import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/firebase_options.dart';
import 'package:flutter_test_app/pages/signin_page.dart';
import 'package:flutter_test_app/pages/signup_page.dart';
import 'package:flutter_test_app/pages/splash_page.dart';
import 'package:flutter_test_app/pages/on_boarding_page.dart';
import 'package:flutter_test_app/services/notification_service.dart';
import 'package:flutter_test_app/utils/app-navigatore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/splash",
      routes: {
        '/splash': (context) => const SplashPage(),
        '/onboarding': (context) => const OnBoardingPage(),
        '/navigator': (context) => const Directionality(
            textDirection: TextDirection.rtl,
            child: AppNavigator()),
        '/signup': (context) => const Directionality(
            textDirection: TextDirection.rtl, child: SignUpPage()),
        '/signin': (context) => const Directionality(
            textDirection: TextDirection.rtl, child: SignInPage()),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
