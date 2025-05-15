import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/create_words_from_image_page.dart';
import 'package:flutter_test_app/pages/home_page.dart';
import 'package:flutter_test_app/pages/profile_page.dart';
import 'package:flutter_test_app/pages/words_page.dart';
import 'package:forui/forui.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigator();
}

class _AppNavigator extends State<AppNavigator> {

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          HomePage(),
          WordsPage(),
          CreateWordsFromImagePage(),
          ProfilePage(),
        ],
      ),

      bottomNavigationBar: FBottomNavigationBar(
        index: index,
       onChange: (index) => setState(() => this.index = index),
        children: [
          FBottomNavigationBarItem(
            icon: FIcon(FAssets.icons.house),
            label: const Text('سەرەکی'),
          ),
          FBottomNavigationBarItem(
            icon: FIcon(FAssets.icons.bookOpen),
            label: const Text('وشەکان'),
          ),
         FBottomNavigationBarItem(
            icon: FIcon(FAssets.icons.camera),
            label: const Text('رەسم'),
          ),
          FBottomNavigationBarItem(
            icon: FIcon(FAssets.icons.user),
            label: const Text('هەژمار'),
          ),


        ],
      ),
    );
  }
}
