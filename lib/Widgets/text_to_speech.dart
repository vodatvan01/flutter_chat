import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class TextToSpeech extends StatefulWidget {
  const TextToSpeech({Key? key}) : super(key: key);

  @override
  State<TextToSpeech> createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech> {
  TextEditingController textEditingController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();

  void textToSpeech(String text) async {
    // langDetect(text);
    await langdetect.initLangDetect();
    await flutterTts.setLanguage(langdetect.detect(text));
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: TextFormField(
                controller: textEditingController,
              ),
            ),
            IconButton(
              onPressed: () {
                textToSpeech(textEditingController.text);
              },
              icon: const Icon(
                Icons.volume_up,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
