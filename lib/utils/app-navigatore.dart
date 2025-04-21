import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/create_words_from_image_page.dart';
import 'package:flutter_test_app/pages/home_page.dart';
import 'package:flutter_test_app/pages/profile_page.dart';
import 'package:flutter_test_app/pages/words_page.dart';
import 'package:forui/forui.dart';

// dway away user login bw basarkawty ayneryn bo /navigator page ka ema am Widgedaman yawa pey
// ama chyakat ?
// ama navigation da anet la bashy xwarawa ka ema click la har navigation item bkain amanxata aw pagewa
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigator();
}

class _AppNavigator extends State<AppNavigator> {
  // la regay am variablawa flutter atwanet bzanet ka kam navigation bar item select krawa
  // sarawa nrxakay 0 ra
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
      // bo bottom navigation baraka libraray ForUi away peshtr daman bazandbw bo Ui amay haya FBottomNavigationBar , ka sarwshkli jwanaw bakary ahenin emash

      bottomNavigationBar: FBottomNavigationBar(
        //propert indexy haya wata la rey amawa azanet ka la sar kam navigation itemaya
        // ka wakw wtman sarata la sar 0ra
        index: index,
        //click la har kamayakian bkayt awa indexy away ka clickman le krdwa acheta naw am varable indexawa letraya
        // a ama alem ↓  dwatr aw functinay lsar runakainw aleyn aw indexay sarawa yaksana ba nrxy aw indexay aw navigation itemy ka clickman le krdwa
        onChange: (index) => setState(() => this.index = index),
        // am childrnash tanha navigation itemakany xwarawamn bo drwstakatw pshan ayat
        children: [
          FBottomNavigationBarItem(
            icon: FIcon(FAssets.icons.house),
            label: const Text('سەرەکی'),
          ),
          FBottomNavigationBarItem(
            icon: FIcon(FAssets.icons.bookOpen),
            label: const Text('وشەکان'),
          ),
          // FBottomNavigationBarItem(
          //   icon: FIcon(FAssets.icons.clipboard),
          //   label: const Text('تاقیکردنەوە'),
          // ),
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
