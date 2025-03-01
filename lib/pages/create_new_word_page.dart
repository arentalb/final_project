import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';

class CreateNewWordPage extends StatefulWidget {
  const CreateNewWordPage({Key? key}) : super(key: key);

  @override
  State<CreateNewWordPage> createState() => _CreateNewWordPageState();
}

class _CreateNewWordPageState extends State<CreateNewWordPage> {
  // ama wakw awany ka bangiakainawa
  final WordsService _wordsService = WordsService();

  // amana la pagekany sarat basm krdwn
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _englishWordController = TextEditingController();
  final TextEditingController _kurdishWordController = TextEditingController();

  @override
  void dispose() {
    _englishWordController.dispose();
    _kurdishWordController.dispose();
    super.dispose();
  }

  // la kasty click krdn la drwstkrdny ordeky taza ama bangakretawa ka la xwarawaya bangman krdotawa
  void _createNewWord() async {
    // wakw pesht basm krdwa , ama serakat bzanet filedakan validn
    if (_formKey.currentState!.validate()) {
      try {
        // ka valid bwn law _wordsService y ka drwstman krdwa la sarawa functiony addNewWord bangakatawa
        // ka awish wsha englizyakawa wsha kwrdyaka anerinawa boy
        await _wordsService.addNewWord(
          _englishWordController.text,
          _kurdishWordController.text,
        );
        // etr lera ka drwstbw pagek achynawa dwawa wata acheawa home page
        Navigator.of(context).pop();
        // wa messegeky pshan ayayn
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('زیاد کرا')),
        );
      } catch (e) {
        // errorish bw errory pshan ayayn
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            // amaman la leading danawa wata la saraty headerakaya
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // ama aw buttonaka ka sahmakay bo dwawaya
              // agareynawa yak page dwaa , agar sery bkait pop() man bang krdotawa
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body:
          // ama bo away btanret scroll bkat bo nmwna ka keyboardaka barz abetawa lawaya shwenman namenet shtakan ba jwani nabinin
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
              // amam baskrdwa
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'زیاد کردنی وشە',
                      style: TextStyle(
                        fontSize: 24
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'دڵنیا بەرەوە لە ئەو وشە و مانایەی کە ئەینوسیت',
                    ),
                    const SizedBox(height: 16),
                    // lera wshaka ba englizy anwsin
                    FTextField(
                      controller: _englishWordController,
                      label: const Text('وشە بە ئینگلحزی'),
                      hint: 'Boat',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'تکایە وشەی ئینگلیزی بنووسە';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // lera wshaka ba kwrdy anwsin
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: FTextField(
                        controller: _kurdishWordController,
                        label: const Text('وشە بە کوردی'),
                        hint: 'بەلەم',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'تکایە وشەی کوردی بنووسە';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ka clickman lam buttona krd aw functinay sarawa run abet
                    FButton(
                      label: const Text('زیاد کردن'),
                      onPress: _createNewWord,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
