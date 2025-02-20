import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //2- ama bo awaya ka rastawxo dastman bgat ab valuey hame filedakan zyatr bas bo validatin bakary ahenin
  // bo nmwna abet useraka email daxlbkat la filedy email , passwordaka la 6 kamtr nabet , la xwarawa zyatr basiakam
  final _formKey = GlobalKey<FormState>();

  //1- amana controllern drwstyanakain bo away btwanyn dastman bgat baw nwsinay ka la har inpt fildeka aynwsin
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

// 10- lerada ka useraka clicky la aw btna krd la stepy 9 ama run abet
// ka run bw yakam sht serakat ka bzanet aw nrxanay la input filedaka zyaman krdwa hamwyan tawawn ?
// amay la regay aw formaawa wa dakat ka la stepy 2 - 3 bom baskrdn
  void _signUp() {
    // alet lam forma currentState hamw valuey hame inputakany laya , functiony validate lasar run akat
    // ka agar hamw inputakan aw validashnay boman danawn wakw stepy 5 wa awany kash agar hamwyan keshayn nabet am true agarenetawa
    // agarish har yakekishian bet keshay tya bet false agarenetawa

    if (_formKey.currentState!.validate()) {
      // ama leraya ema request aneryn bo firebase ka userek drwstbkat ba pey aw shtanay kasaka daxli krdwa
      // wa harwaha SnackBarekish drwstakainw pshany ayayn la bashy xwaraway shashaka ka aw namayay tyaya
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هەژمارەکەت دروست کرا')),
      );
      // dway away requestakaman nardw hich keshay tya nabw ema aw userman drwstkrd boya dway awa ema ayxayna pagey login bo away ba asany btwanet daxl bbet
      Navigator.pushNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            //3- amaman bakarnahena la jami3a ta esta ama har widgeky taza ka hamw enput filedakanman akaina naw amawa
            // am keyaya ayayne bo away bynsenin ka amash aw varaiableaya ka la stepy 2 pem wtn
            // ta est ama tanha nasandenty bakarman nahenawa , dwatr petanalem la stepakani ka
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "هەژمار دروست بکە",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "زانیاریەکانت بنووسە بۆ دروستکردنی هەژمارەکەت",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  //4- ama input fildeka ka controllerakay ka bo amaman drwst krdwa ayyne
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "ناوی تەواو",
                    border: OutlineInputBorder(),
                  ),
                  //5- ama hich  elaqay ba awawa nia ka la stepy 3 bom baskrdn
                  // lera hamw TextFormField amd fileday haya ka functionek waragret
                  // la naw functionakaya aw shatay nwsiwmana lam daqaya la input filedakaya
                  //ayxata aw variabley ka nawman nawa (value)
                  validator: (value) {
                    //6- ama agar aw valuey ka la input filedakaya batal bw yan null be la error messjakaya aw nwsinamn bo anwset
                    if (value == null || value.isEmpty) {
                      return 'تکایە ناوت بنووسە';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "ئیمەیل",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    //7 amash bahamn sheway away sarawaya step5 balam ema checky dw shtakain
                    // serakain bzanin hichy la inputsaka nwsiawa
                    if (value == null || value.isEmpty) {
                      return 'تکایە ئیمەیلەکەت بنووسە';
                    }
                    // seriakain bzanin shewazy emaila bo nmwna kotay bet ba @gmail.com
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'تکایە ئیمەیلەکە بە شێوازی دروست بنووسە';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "وشەی نهێنی",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تکایە وشەی نهێنیەکەت بنووسە';
                    }
                    //8 ama seriakat bzanet away nwsywety kamtra la 6 pyt agar kamr bw aw message pshanayat
                    if (value.length < 6) {
                      return 'وشەی نهێنی پێویستە زیاتر لە ٦ پیت بێت';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  // 9 - ama aw btnaya ka useraka ka clicky le krd functiony _signUp run abet ka la sarawa nasandwmana
                  //  bo stepy 10 bchora sarawa
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: const Text("تۆمارکردن"),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    //11 - ama aw nwsina shinay xwarawa ka la regay amawa achina pageky ka
                    // ka clicky lama krd achet bo aw pagey ka nawakaman yawa pey (\signup) ka la filey main.dart nasandwmana
                    // ama xoy texteka ka la xwarawa aybynyt bas abet ba shewazek bzanin ka kay clicky le akat boya xstwmanata naw  GestureDetector
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: const Text(
                    "پێشتر هەژمارم هەیە؟ چونە ژوورەوە",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
