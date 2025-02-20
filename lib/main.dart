import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/firebase_options.dart';
import 'package:flutter_test_app/pages/home_page.dart';
import 'package:flutter_test_app/pages/signin_page.dart';
import 'package:flutter_test_app/pages/signup_page.dart';
import 'package:flutter_test_app/utils/auth_checker.dart';

void main() async {
  // la skaty saratay run buny appaka pewista takid bkretawa ka firebase bataawawaty run bwaw connect bwa
  // krdwmana ba async wa awaity amay xwarawaman krdwa chwnka ama eshaeka request anerert la rey internetawa boya abet async/ await bbet
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //yakam page bo away bcheta sary dway dagyrsany barnamaka
      initialRoute: "/auth",
      routes: {
        '/auth': (context) =>
            AuthChecker(), // ama tanha bo awaya ka checky awabkat ka userka logina yan na agar harkamian bw ayneret bo pagekani ka
        // aw pagenay hamana ayannasenin , text ka la peshyawa / haya bawaya atwanyt bchina aw page , wa widgey aw pagey ayayne ka fileka xomand drwstman krdwa
        '/home': (context) => const Directionality(
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
