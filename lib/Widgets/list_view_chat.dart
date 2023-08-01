import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class ListViewChat extends StatefulWidget {
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
  State<ListViewChat> createState() {
    return _ListViewChatState();
  }
}

class _ListViewChatState extends State<ListViewChat>
    with SingleTickerProviderStateMixin {
  void textToSpeech(String text) async {
    await langdetect.initLangDetect();
    await widget.flutterTts.setLanguage(langdetect.detect(text));
    await widget.flutterTts.setVolume(0.5);
    await widget.flutterTts.setSpeechRate(0.5);
    await widget.flutterTts.setPitch(1);
    await widget.flutterTts.speak(text);
  }

  // Future<void> _getAPIKeyFromFirestore() async {
  //   try {
  //     // Lấy API key từ Firestore
  //     var collection = FirebaseFirestore.instance.collection('APIKey');
  //     var snapshot = await collection
  //         .doc('kZZJdmsZk03CZ80J8Sj0')
  //         .get(); // Chỉnh sửa kiểu của biến snapshot
  //     if (snapshot.exists) {
  //       Map<String, dynamic> data = snapshot.data()!;
  //       String apiKey = data['apikey'];
  //     } else {}
  //   } catch (e) {
  //     print("Error fetching API key: $e");
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _getAPIKeyFromFirestore(); // Gọi phương thức lấy API key
  // }

  Future<void> saveMessageToFirestore() async {
    try {
      String documentId = "27KRbfhQzxrlwgR0bS2M";

      // Tạo dữ liệu mảng từ danh sách tin nhắn của người dùng và bot
      List<String> humanMessagesList = List.from(widget.humanMessages.reversed);
      List<String> botAIMessagesList = List.from(widget.botAIMessages.reversed);

      // Thêm dữ liệu vào Firestore
      await FirebaseFirestore.instance
          .collection("history")
          .doc(documentId)
          .set({
        "humanMessages": humanMessagesList,
        "botAIMessages": botAIMessagesList,
      });
      // print("****************************");
      // print("Data saved to Firestore successfully!");
    } catch (e) {
      // print("****************************");
      // print("Error saving data to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: widget.humanMessages.length,
      itemBuilder: (context, index) {
        saveMessageToFirestore();
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
                      color: Colors.cyanAccent.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.humanMessages[
                          (widget.humanMessages.length - index - 1)],
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
                  const SizedBox(height: 8),
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
                      widget.botAIMessages[
                          (widget.botAIMessages.length - index - 1)],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      textToSpeech(widget.botAIMessages[
                          (widget.botAIMessages.length - index - 1)]);
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
