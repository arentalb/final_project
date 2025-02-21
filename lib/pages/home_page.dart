import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // la rey amawa dastman agar  ba datay aw userakay ka login bwa
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = AuthService();

  void _signOut() async {
    // ka clikman la btny logout krd awa am functiona run abet useraka akata darawa la appakaw logouty akat ka logicakayman la AuthService danawa methosuy logout lawe
    await _auth.signout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('چویتە دەرەوە')),
    );

    //dwatr useraka axaynawa pagy signin
    Navigator.pushNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user != null)
              Column(
                children: [
                  Text("یای دی: ${user?.uid}", style: TextStyle(fontSize: 18)),
                  Text("ئیمەیڵ: ${user?.email}", style: TextStyle(fontSize: 18)),
                  Text("ناو : ${user?.displayName ?? 'نەناسراو'}",
                      style: TextStyle(fontSize: 18)),
                ],
              )
            else
              Text("هیچ بەکارهێنەرێک نیە", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text("چوونە دەرەوە"),
            ),
          ],
        ),
      ),
    );
  }
}
