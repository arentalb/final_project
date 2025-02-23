import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/create_new_word_page.dart';
import 'package:flutter_test_app/services/words_service.dart';
import 'package:forui/forui.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // lera WordsService bangakaynawa
  final _wordService = WordsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // away lam paddingayaya headerakaya bo pshan yani headeraka ka buttoneky tyaya la rey awawa achina pageky ka bo away wshay taza zyad bkain
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "وشەکانی ئەمڕۆ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // am buttona ka clickman le krd pagey CreateNewWordPage man bo akatawa ba shewazek ka buttoneky haya rwy krdota dwawa
                  // ka atwanyn ba asany bgareynawa era
                  FButton(
                    label: const Text('وشەی تازە'),
                    onPress: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateNewWordPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
              // lera expandedman danawa bo away tawawy shashaka bgret
            Expanded(
              // childy ama  StreamBuilder<QuerySnapshot> ka la rey amawa ka flutter xoy alet ama ba kar bhena
              // am codesha la documentashny xoyanawa henawmana agar mamosta qsay krd lamaya ble xoyan wtwyana awa bakary bhenn

              child: StreamBuilder<QuerySnapshot>(
                // lam StreamBuilder<QuerySnapshot> shtekman haya banawy stream ka ama connectabet ba firebasawa
                // la katy zyadbwny har datayaki taza rastawxo ama run abetawa aw data tazayam bo pshanayatawa la uiaka

                stream: _wordService.getTodayWordsStream(),
                builder: (context, snapshot) {
                  // snapshot leraya mabasty awaya ka wakw awa waya rasmeky datakan bgret chy habet law daqaya aygarenatwa la databaysa , boy al naw aw
                  // snapshotaya hamw datakanmn haya

                  //agar errory tya be amam pshan ba
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // agar loding bw amam pshan a
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // agar batal bw ama pshan ba wata hich datayaki tya nabw
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text("No words available"));
                  }
                  // agar awany sarawa hichyan nabw awa listek la datakan pshan ayayanawa
                  // ka leraya list builderman bakarhenawa bo datay ka la serverawa bet basha
                  return ListView.builder(
                    // pewista 3adadakay peblein , 3adaday aw datayanay ka ahamana , amash la naw aw variable docs .lenght bangakain ka 3adadakaiman pe alet
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;
                      // ama datakaman rekaxain ka atwanin bam shewaza data['kurdishWord'] datay nawawayman dastbkawet
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // wsha kwrdyaka
                              Text(
                                data['kurdishWord'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              // wsha englizyaka
                              Text(
                                data['englishWord'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
