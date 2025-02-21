import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/auth_service.dart';
import 'package:forui/forui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FAvatar.raw(child: const Text('MN')),
                  TextButton(
                    onPressed: _signOut,
                    child: FAvatar.raw(
                      child: FIcon(
                        FAssets.icons.arrowLeftToLine,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1)),
            ),
            SizedBox(
              height: 12,
            ),

            if (user != null)
              Padding(padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(" ${user?.displayName}", style: TextStyle(fontSize: 22)),
                  Text("  ${user?.email ?? 'نەناسراو'}",
                      style: TextStyle(fontSize: 14)),
                ],
              ),)
            else
              Text("هیچ بەکارهێنەرێک نیە", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
