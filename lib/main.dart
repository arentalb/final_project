import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/home_page.dart';
import 'package:flutter_test_app/pages/signin_page.dart';
import 'package:flutter_test_app/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //yakam page bo away bcheta sary dway dagyrsany barnamaka
      initialRoute: '/signup',
      routes: {
        // aw pagenay hamana ayannasenin , text ka la peshyawa / haya bawaya atwanyt bchina aw page , wa widgey aw pagey ayayne ka fileka xomand drwstman krdwa
        '/': (context) => const Directionality(
            //bo har danayak directionality ayayne bo awa nwsinakan la rastawa bo chap bn (rtl)
            textDirection: TextDirection.rtl,
            child: HomePage()),
        '/signup': (context) => const Directionality(
            textDirection: TextDirection.rtl, child: SignUpPage()),
        '/signin': (context) => const Directionality(
            textDirection: TextDirection.rtl, child: SignInPage()),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
