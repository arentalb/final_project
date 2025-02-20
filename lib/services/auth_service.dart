import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // ama lera instancy firebase waragrin hy FirebaseAuth ka packagenak dawnloadman krdwa xoy am shtanay hamwy implemnet krdwa
  //ema bas bakary ahenin
  final _authInstance = FirebaseAuth.instance;
  Future<User?> signup(String email, String password, String name) async {
    // am functiona se shty bo anerin bo firebase ka useraka drwst bkayn
    // bo awaya ka useraka daxil bkayn email , password , name man awet
    // wa ayxayna try catchawa
    try {
      // lasar aw instansay ka warman grtwaw a variabley _authInstance xaznman krdwa functionek haya ba nawy
      //createUserWithEmailAndPassword ka abet emailw passwordy bo bnerin
      //aw functionash shtekman bo agarenetawa ka la jory UserCredential emash la naw userCredential xazny akain
      UserCredential userCredential = await _authInstance
          .createUserWithEmailAndPassword(email: email, password: password);
      // la naw userCredential userman haya ka userakaya la databasey firebase drwsty krdwa
      User? user = userCredential.user;

      // seriakain bzanin agar hatw batal nabw awa nawakay bo zyad akain bo aw useray ba emailw password zyadman krdbw
      if (user != null) {
        await user.updateProfile(displayName: name);
        await user.reload();
        user = _authInstance.currentUser;
      }
      return user;

// agar har errorek rwy ya bo nmwna emaialkay baharhenawa peshtr yakeki ka
// awa leraya azanin ka chyaw atwanyn namaka xoman throwy kain bo away la ui la katy bang krdny am functiona ka krdwmanata try catchawa am erroray bo fre ayayn awish
// lawe aygretw la uiaka pshany ayat
    } on FirebaseAuthException catch (e) {
      // ama firebase xoy am nawanay danawa , agar hatw passwordeky za#yf bnerin am "weak-password" amaman bo da anet la filedy code la naw aw erroroy ka ayneretawa
      if (e.code == 'weak-password') {
        throw 'پاسۆردەکەت ضعیفە';
        // amashyan ba hamn shewa agar hatw emaialka peshtr bakarhatbw amaman bo aneretawa
        // etr ema awata chacky harwkianman krdwa har kam kesha rwbat ema messgek taybat bawa agareninawa
      } else if (e.code == 'email-already-in-use') {
        throw 'ئیمەیلەکەت پێشتر بەکارهێنراوە';
      }
      // agar hich cam law errororna nabw shty kabw tanha awa agareninawa ka shteki xalat rwy yawaw emash nazanin chya
    } catch (e) {
      throw 'هەڵەیەک ڕوویدا';
    }
    return null;
  }

  Future<User?> signin(String email, String password) async {
    try {
      // amashyan ba hamn sheway away sarawa tanh aawaya ama signInWithEmailAndPassword bakarahenin bo away daxli system bbin
      UserCredential userCredential = await _authInstance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // jory error codeka bo amayan jyaya ka amaya
      if (e.code == 'invalid-credential') {
        throw ' پاسسۆردەکەت هەڵەی یان هەژمارەکەت نەدۆزرایەوە';
      }
    } catch (e) {
      throw 'هەڵەیەک ڕوویدا';
    }
    return null;
  }

// amash aagr wystman darchin la shsytemaka
  Future<void> signout() async {
    await _authInstance.signOut();
  }
}
