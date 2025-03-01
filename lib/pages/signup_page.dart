import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/auth_service.dart';
import 'package:forui/forui.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

// 1- amash bahamn sheway signin pagekaya
class _SignUpPageState extends State<SignUpPage> {
  // instancek law servica drwstakain ka bo drwstkrdny account bo away btwany methodakani bakar bhenin
  final _auth = AuthService();

  //2- ama bo awaya ka rastawxo dastman bgat ab valuey hame filedakan zyatr bas bo validatin bakary ahenin
  // bo nmwna abet useraka email daxlbkat la filedy email , passwordaka la 6 kamtr nabet , la xwarawa zyatr basiakam
  final _formKey = GlobalKey<FormState>();

  //1- amana controllern drwstyanakain bo away btwanyn dastman bgat baw nwsinay ka la har inpt fildeka aynwsin
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

// 10- lerada ka useraka clicky la aw btna krd la stepy 9 ama run abet
// ka run bw yakam sht serakat ka bzanet aw nrxanay la input filedaka zyaman krdwa hamwyan tawawn ?
// amay la regay aw formaawa wa dakat ka la stepy 2 - 3 bom baskrdn
  void _signUp() async {
    // alet lam forma currentState hamw valuey hame inputakany laya , functiony validate lasar run akat
    // ka agar hamw inputakan aw validashnay boman danawn wakw stepy 5 wa awany kash agar hamwyan keshayn nabet am true agarenetawa
    // agarish har yakekishian bet keshay tya bet false agarenetawa
    if (_formKey.currentState!.validate()) {
      // ama leraya ema request aneryn bo firebase ka userek drwstbkat ba pey aw shtanay kasaka daxli krdwa
      // wa harwaha SnackBarekish drwstakainw pshany ayayn la bashy xwaraway shashaka ka aw namayay tyaya
      try {
        // ama esta aw functiona bangakain ka bo drwstkrdny user la AuthService aw classay drwstman krdwa
        final user = await _auth.signup(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );

        // shtek agarenetawa agar hatw useraka tawaw bw 3ayby nabe aygarenetawa ema la user xazny akain
        // agar hatw keshay hamw nulll agarenetawa
        if (user != null) {
          // ka keshay nabet ema ayxayan page home wa messejekishy pshanayayn
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هەژمارەکەت دروست کرا')),
          );
          Navigator.pushNamed(context, '/navigator');
        }
      } catch (e) {
        // ka keshay habw ema messejekishy pshanayayn
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ama bo awaya ka agar hatw shty zorman tya dana la screeny bcheka ama bbet ba scroller wahta btwanret scrolly bkain
            //tananat la screny gawrasha agar hatw ema keyboardakay xwarawaman krdwa bahoy amawa UI aya jwan darachetw atwanret hamwy bbynin shtakani nawi ba shewayaky scroll
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "هەژمار دروست بکە",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "زانیاریەکانت بنووسە بۆ دروستکردنی هەژمارەکەت",
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 50),
                              //3- amaman bakarnahena la jami3a ta esta ama har widgeky taza ka hamw enput filedakanman akaina naw amawa
                              // am keyaya ayayne bo away bynsenin ka amash aw varaiableaya ka la stepy 2 pem wtn
                              // ta est ama tanha nasandenty bakarman nahenawa , dwatr petanalem la stepakani ka
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ama ka nwsrawa F la peshyawa ama har wakw text input filedakaya ka la jami3a xwendwmana
                                    // bas awaya ama la packagey 'package:forui/forui.dart'; importman krdwa agar la saraway am file serikayt
                                    // aybynyt ka importman krdwa , ama ka ema rastawxo am packaga bakarahenin wakw waya har awa bkarbenin ka ba defaulty la naw
                                    // fluteraya tanha awaya amayan desigininan bo krdwaw jwanish
                                    FTextField(
                                      controller: _nameController,
                                      label: const Text("ناوی تەواو"),
                                      hint: "ناوت بنووسە",
                                      maxLines: 1,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'تکایە ناوت بنووسە';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // ama wakw wtm law packaga daman bazandwa
                                    // atwanin bo aw filedanay passwordn yan emailn .email yan .password dabnenin bo hane sht ka xoy la pshatawa aykat
                                    FTextField.email(
                                      controller: _emailController,
                                      label: const Text("ئیمەیل"),
                                      hint: 'example@gmail.com',
                                      maxLines: 1,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'تکایە ئیمەیلەکەت بنووسە';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                          return 'تکایە ئیمەیلەکە بە شێوازی دروست بنووسە';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    FTextField.password(
                                      controller: _passwordController,
                                      obscureText: true,
                                      label: const Text("وشەی نهێنی"),
                                      hint: '* * * * * * * *',
                                      maxLines: 1,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'تکایە وشەی نهێنیەکەت بنووسە';
                                        }
                                        if (value.length < 6) {
                                          return 'وشەی نهێنی پێویستە زیاتر لە ٦ پیت بێت';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    // am buttonash bahamn shewa law packaga hatwa
                                    // harshtek F y pewa bwa wata law packagawa hatwa
                                    FButton(
                                      label: const Text('تۆمارکردن'),
                                      onPress: _signUp,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("پێشتر هەژمارم هەیە؟"),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/signin');
                                    },
                                    child: const Text(
                                      "چونە ژوورەوە",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
