import 'package:chatbot_app/Widgets/list_view_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatScreen({
    super.key,
    required this.apiKey,
    required this.isValidAPIKey,
    required this.chatList,
    required this.documentCount,
    required this.humanMessages,
    required this.botAIMessages,
    required this.chatConversation,
    required this.onHomePressed,
  });

  final String apiKey;
  final bool isValidAPIKey;
  final List<dynamic> chatList;
  final int documentCount;
  final List<String> botAIMessages;
  final List<String> humanMessages;
  String chatConversation;
  final VoidCallback onHomePressed;
  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _hasText = false;
  bool checkConversation = true;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final FlutterTts _flutterTts = FlutterTts();
  String promt = '';
  String historyID = ' ';
  bool titleText = true;
  String chatTitle = '';

  void saveToFirestore() async {
    try {
      Map<String, dynamic> newChat = {
        'humanMessages': widget.humanMessages,
        'botAIMessages': widget.botAIMessages,
        'chatconversation': widget.chatConversation,
        'ChatTitle': chatTitle,
      };
      print('${widget.chatList.length}  _____________ ${widget.documentCount}');
      widget.chatList.length == widget.documentCount
          ? widget.chatList.add(newChat)
          : widget.chatList[widget.documentCount - 1] = newChat;

      await FirebaseFirestore.instance
          .collection("Memory")
          .doc('ChatHistory')
          .set({'ListChatHistory': widget.chatList});

      print('Dữ liệu đã được lưu vào Firestore thành công.');
    } catch (e) {
      print('Lỗi khi lưu dữ liệu vào Firestore: $e');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _textEditingController.text = _lastWords;
              _hasText = true;
            });
          },
          localeId: 'vi_VN',
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  Future<void> _handleSummitted(String text) async {
    setState(() {
      widget.humanMessages.add(text);
      widget.chatConversation += 'Human: $text.';
      widget.botAIMessages.add("...");
      _textEditingController.clear(); // Xóa văn bản trong ô nhập liệu
      _hasText = false; // Xóa văn bản và cập nhật biểu tượng thành thoại
    });
    String aiResponse = await _getAIResponse(text);

    for (int i = 0; i < aiResponse.length; i += 3) {
      await Future.delayed(const Duration(milliseconds: 50));
      String partialResponse = '${aiResponse.substring(0, i + 1)}▌';
      setState(() {
        if (widget.botAIMessages.isNotEmpty) {
          widget.botAIMessages[widget.botAIMessages.length - 1] =
              partialResponse;
        }
      });
    }

    // Cập nhật toàn bộ câu trả lời của bot AI sau khi hiển thị từng ký tự
    setState(() {
      widget.botAIMessages[widget.botAIMessages.length - 1] = aiResponse;
      widget.chatConversation += '\nAi: $aiResponse';
    });
    if (widget.humanMessages.length == 1 && widget.botAIMessages.length == 1) {
      await _createTitle();
    }

    saveToFirestore();
  }

  Future<String> _getAIResponse(String userInput) async {
    try {
      // Đặt API key bằng cách gọi setter
      OpenAI.apiKey = widget.apiKey;

      // Gọi API GPT-3 để lấy phản hồi từ AI
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: "${widget.chatConversation}\nAi: ",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      // Trích xuất phản hồi từ response
      String aiResponse = chatCompletion.choices.first.message.content;
      return aiResponse;
    } catch (e) {
      if (e.toString().contains('statusCode: 429')) {
        return 'Tài khoản của bạn bị giới hạn 3 req/min, hãy nâng cấp hoặc thử lại sau 20s.';
      } else {
        return "Error: Unable to get AI response.";
      }
    }
  }

  Future<void> _createTitle() async {
    try {
      // Đặt API key bằng cách gọi setter
      OpenAI.apiKey = widget.apiKey;

      // Gọi API GPT-3 để lấy phản hồi từ AI
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content:
                "hãy tạo tiêu đề với cuộc trò chuyện ${widget.chatConversation}\ntiêu đề là tiếng việt, tối đa 20 ký tự \nTitle : ",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      // Trích xuất phản hồi từ response
      String aiResponse = chatCompletion.choices.first.message.content;
      setState(() {
        chatTitle = aiResponse;
      });
    } catch (e) {
      print('ERRO create Title ____________________: $e');
      setState(() {
        chatTitle = 'statusCode: 429';
      });
    }
  }

  void _alertDialog() {
    if (!widget.isValidAPIKey) {
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
                        Navigator.of(context).pop();
                        widget.onHomePressed();
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
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _alertDialog();

    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        // drawer: const ChatDrawer(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent.shade100,
                Colors.pinkAccent.shade100,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListViewChat(
                  humanMessages: widget.humanMessages,
                  botAIMessages: widget.botAIMessages,
                  flutterTts: _flutterTts,
                ),
              ),
              if (widget.botAIMessages.isNotEmpty)
                Container(
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      widget.chatConversation = widget
                          .chatConversation
                          .substring(
                              0,
                              widget.chatConversation.length -
                                  (widget
                                          .botAIMessages[
                                              widget.botAIMessages.length - 1]
                                          .length +
                                      widget
                                          .humanMessages[
                                              widget.humanMessages.length - 1]
                                          .length +
                                      13));

                      String humanMessEnd =
                          widget.humanMessages[widget.humanMessages.length - 1];
                      setState(() {
                        widget.botAIMessages
                            .removeAt(widget.botAIMessages.length - 1);
                        widget.humanMessages
                            .removeAt(widget.humanMessages.length - 1);
                      });
                      _handleSummitted(humanMessEnd);
                    },
                    child: const Icon(Icons.restart_alt),
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
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration.collapsed(
                            hintText: 'Send a message'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _hasText
                          ? () {
                              print(
                                  'Chat_______________${widget.documentCount}');
                              _handleSummitted(_textEditingController.text);
                            }
                          : () {
                              _listen();
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
      ),
    );
  }
}
