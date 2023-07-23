import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textEditingController = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleSummitted(String text) {
    print("Text entered: $text");
    _textEditingController.clear();
    setState(() {
      _hasText = false; // Xóa văn bản và cập nhật biểu tượng thành thoại
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot Flutter'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return Container(
                  height: 50,
                  // color: Colors.red,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    onChanged: (value) {
                      setState(() {
                        _hasText = value.isNotEmpty;
                      });
                    },
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Send a message'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _hasText
                      ? () {
                          _handleSummitted(_textEditingController.text);
                        }
                      : () {
                          // xu ly voice
                        },
                  icon:
                      _hasText ? const Icon(Icons.send) : const Icon(Icons.mic),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
