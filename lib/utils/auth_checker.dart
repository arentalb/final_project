import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test_app/pages/signin_page.dart';
import 'package:flutter_test_app/services/navigatore.dart';

// ama aw widgeya ka har barnamaka run bu yata naw amawa ka la routy /auth daman nawa
// ama checky awa akt aya useraka login bwa peshtr ?
// agar login bbw ayneret bo route /home
// agar login nabwbw ayneret bo routy login
class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ama future buildera , wakw list builder waya , boya nawi feturea yani dahatw ka ama abet bakarbenin bo away esh lagal authentication firebasa bkain leraya
    return FutureBuilder<User?>(
      // ama widgea propertyakay haya ba nawy future ka ema shteki bo aneryn ka etr la backgrounda chaecky awa akat aya am user login bwa peshtr yan na wa aw valuay aygarenatawa ayxata naw snapshootawa
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        // seri connectionState agar waiting bw awa baznayaki xrman pshan ayat la nawarasty screenaka
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        // la snapshota serakat bzanet filedy hasData true a agar true bw awa wata useraka login bwa peshtr boya AppNavigatry pshan ayayn
        if (snapshot.hasData) {
          return const AppNavigator();
        }
        // agar na waiting bw na hasData true bw awa dyara useraka login nabwa peshtrw SignInPage agarenetawa
        return const SignInPage();
      },
    );
  }
}
