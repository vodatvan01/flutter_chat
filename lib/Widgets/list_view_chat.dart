import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class ListViewChat extends ConsumerStatefulWidget {
  const ListViewChat({
    super.key,
    required this.humanMessages,
    required this.botAIMessages,
    required this.flutterTts,
  });

  final List<String> humanMessages;
  final List<String> botAIMessages;

  final FlutterTts flutterTts;

  @override
  ConsumerState<ListViewChat> createState() {
    return _ListViewChatState();
  }
}

class _ListViewChatState extends ConsumerState<ListViewChat>
    with SingleTickerProviderStateMixin {
  // String _documentID = '';
  void textToSpeech(String text) async {
    await langdetect.initLangDetect();
    await widget.flutterTts.setLanguage(langdetect.detect(text));
    await widget.flutterTts.setVolume(0.5);
    await widget.flutterTts.setSpeechRate(0.5);
    await widget.flutterTts.setPitch(1);
    await widget.flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // reverse: true,
      itemCount: widget.humanMessages.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 30),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.humanMessages[index],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromARGB(255, 18, 6, 50),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromARGB(255, 105, 133, 231),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/chatbot.png'),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.botAIMessages[index],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      textToSpeech(widget.botAIMessages[index]);
                    },
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
