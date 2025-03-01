import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).pushNamed("/navigator");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    final titleStyle = TextStyle(
      fontSize: 26.0,
      fontWeight: FontWeight.bold,
      color: colorScheme.primary,
    );

    final bodyStyle = TextStyle(
      fontSize: 18.0,
      color: colorScheme.primary,
    );
    final pageDecoration = PageDecoration(
      titleTextStyle: titleStyle,
      bodyTextStyle: bodyStyle,
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
      contentMargin: const EdgeInsets.symmetric(vertical: 16),
      imageFlex: 3,
      bodyFlex: 2,
      footerFlex: 1,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      rtl: true,
      pages: [
        PageViewModel(
          title: "بەخێربێیت بۆ بەرنامەکەمان ",
          body: "ئەم بەرنامەیە سیستەمی لایتنەر بەکار دەهێنێ بۆ فێربوون بەشێوازی کاریگەر.",
          image: Image.asset('assets/illu-1.jpg', width: 400),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "چۆن کاردەکات؟",
          body: "ئەو وشانەی ئەتەوێت بیرت نەچێتەوە زیادیان ئەکەیت ، ئێمەش کاتێکت بۆ دادەنێین بۆ ئەنجامدانی تاقیکردنەوە",
          image: Image.asset('assets/illu-2.jpg', width: 400),
          decoration: pageDecoration,
        ),

        PageViewModel(
          title: "ئیتر هیچ لە بیر ناکەیت ",
          image: Image.asset('assets/illu-3.jpg', width: 400),
          decoration: pageDecoration,
          bodyWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ئێستا ئامادەی  هیچ لە بیر نەکەیت ؟ دەستپێبکە",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FButton(
                  onPress: () => _onIntroEnd(context),
                  label: const Text("دەستپێبکە"),
                ),
              )
            ],
          ),
        ),
      ],

      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(
        'تێپەڕێنە',
        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
      ),
      next: Icon(Icons.arrow_back, color: colorScheme.primary), // In RTL, next points left
      done: Text(
        'دەستپێبکە',
        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: colorScheme.primary.withOpacity(0.3),
        activeSize: const Size(22.0, 10.0),
        activeColor: colorScheme.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
