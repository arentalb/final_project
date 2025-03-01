import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkAppFlow();
  }

  Future<void> checkAppFlow() async {
    await Future.delayed(const Duration(seconds: 3));

    final isFirstTime = await checkIfFirstTime();
    final user = FirebaseAuth.instance.currentUser;

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');//onboarding
    } else if (user != null) {
      Navigator.pushReplacementNamed(context, '/navigator');//navigator
    } else {
      Navigator.pushReplacementNamed(context, '/signin');//signin
    }
  }

  Future<bool> checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('first_launch', false);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/logo-v3.png'),
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            LoadingAnimationWidget.waveDots(
              color: Colors.black,
              size: 25
            ),
          ],
        ),
      ),
    );
  }
}
