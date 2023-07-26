import 'package:chatbot_app/providers/api_key_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _hasText = false;
  final List<String> _humanMassage = [];

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleSummitted(String text) {
    // print("Text entered: $text");

    setState(() {
      _humanMassage.add(text);
      _textEditingController.clear(); // Xóa văn bản trong ô nhập liệu
      _hasText = false; // Xóa văn bản và cập nhật biểu tượng thành thoại
    });
  }

  // void _goToHomeScreen() {

  // }

  void _alertDialog() {
    if (ref.watch(apiKeyProvider.notifier).state == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('warning'),
              content: const Text('Please enter API key.'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigator.of(context).pop();
                      },
                      child: const Text(
                        'OK',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _alertDialog();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 63, 17, 177),
              Color.fromARGB(255, 130, 87, 240),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Đảo ngược thứ tự các mục trong danh sách
                itemCount: _humanMassage.length,
                itemBuilder: (context, index) {
                  // Hiển thị các tin nhắn đã gửi/nhận trên màn hình
                  return Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width *
                                      0.6, // Giới hạn chiều rộng tối đa của tin nhắn
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber, // Màu nền của tin nhắn
                                  borderRadius: BorderRadius.circular(
                                      2), // Bo tròn các góc
                                ),
                                child: Text(
                                  _humanMassage[
                                      (_humanMassage.length - index - 1)],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const CircleAvatar(
                                // Bọc biểu tượng trong widget CircleAvatar
                                backgroundColor: Colors.amber,
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
                            // phản hồi từ AI
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                // Bọc biểu tượng trong widget CircleAvatar
                                backgroundColor: Colors.amber,
                                child: Icon(
                                  Icons.computer,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber, // Màu nền của tin nhắn
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  'phan hoi tu AI',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ));
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
                    icon: _hasText
                        ? const Icon(Icons.send)
                        : const Icon(Icons.mic),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
