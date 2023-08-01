import 'package:chatbot_app/Widgets/list_view_chat.dart';
import 'package:chatbot_app/providers/api_key_provider.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  final List<String> _humanMessages = [];
  final List<String> _botAIMessages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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
    String aiResponse = await _getAIResponse(text);

    setState(() {
      _humanMessages.add(text);
      _botAIMessages.add(aiResponse);
      _textEditingController.clear(); // Xóa văn bản trong ô nhập liệu
      _hasText = false; // Xóa văn bản và cập nhật biểu tượng thành thoại
    });
  }

  Future<String> _getAIResponse(String userInput) async {
    try {
      // Đặt API key bằng cách gọi setter
      OpenAI.apiKey = ref.read(apiKeyProvider.notifier).state.toString();

      // Gọi API GPT-3 để lấy phản hồi từ AI
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: userInput,
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      // Trích xuất phản hồi từ response
      String aiResponse = chatCompletion.choices.first.message.content;
      return aiResponse;
    } catch (e) {
      return "Error: Unable to get AI response.";
    }
  }

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
                        Navigator.of(context).pop();
                        // thêm chức năng chuyển tới homescreen
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
              humanMessages: _humanMessages,
              botAIMessages: _botAIMessages,
              flutterTts: _flutterTts,
            )),
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
    );
  }
}
