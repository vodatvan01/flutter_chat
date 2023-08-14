import 'package:chatbot_app/Widgets/list_view_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.apiKey,
    required this.documentCount,
    required this.documentID,
    required this.isValidAPIKey,
    required this.onHomePressed,
    required this.resetChat,
    required this.onResetChatPressed,
    required this.deleteChat,
    required this.onDeleteChatPressed,
    required this.onSetSatePressed,
  });

  final String apiKey;
  final int documentCount;
  final String documentID;
  final bool isValidAPIKey;
  final VoidCallback onHomePressed;
  final bool resetChat;
  final VoidCallback onResetChatPressed;
  final bool deleteChat;
  final VoidCallback onDeleteChatPressed;
  final void Function() onSetSatePressed;

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _hasText = false;
  final List<String> _humanMessages = [];
  final List<String> _botAIMessages = [];
  final List<String> chatTitle = [];
  var chatConversation = '';
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  bool dlt = true;
  final FlutterTts _flutterTts = FlutterTts();
  String promt = '';
  String historyID = ' ';
  bool titleText = false;

  // String _documentID =

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> getMessageFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("Chat_history")
          .doc(widget.documentID.isEmpty
              ? 'history_${widget.documentCount}'
              : widget.documentID)
          .get();
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        List<dynamic> humanMes = data["humanMessages"] as List<dynamic>;
        List<dynamic> botAIMes = data["botAIMessages"] as List<dynamic>;

        setState(() {
          chatConversation = data["chatConversation"];
          // print(humanMes[0]);
          _humanMessages.clear();
          _botAIMessages.clear();
          _humanMessages.addAll(List<String>.from(humanMes.reversed));
          _botAIMessages.addAll(List<String>.from(botAIMes.reversed));
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error getting data from Firestore: $e");
    }
  }

  Future<void> getChatTitlesFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Chat_titles')
          .doc('chatTitle')
          .get();
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        List<dynamic> chatttls = data['title'] as List<dynamic>;
        print(
            '***chat***_______________________ChatTitle2 :${chatttls.length}');

        setState(() {
          chatTitle.clear();
          chatTitle.addAll(List<String>.from(chatttls));
        });
      } else {
        // ignore: avoid_print
        print("Document does not exist.");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error getting data from Firestore: $e");
    }
  }

  Future<void> saveChatTitlesToFirestore() async {
    try {
      // Thêm dữ liệu vào Firestore
      await FirebaseFirestore.instance
          .collection('Chat_titles')
          .doc('chatTitle')
          .set({"title": chatTitle});
      print("****************************");
      print("Data saved to Firestore successfully!");
    } catch (e) {
      // print("****************************");
      // ignore: avoid_print
      print("Error saving data to Firestore: $e");
    }
  }

  Future<void> saveMessageToFirestore() async {
    try {
      // Tạo dữ liệu mảng từ danh sách tin nhắn của người dùng và bot
      List<String> humanMessagesList = List.from(_humanMessages.reversed);
      List<String> botAIMessagesList = List.from(_botAIMessages.reversed);
      // String chatConver =
      // Thêm dữ liệu vào Firestore
      await FirebaseFirestore.instance
          .collection("Chat_history")
          .doc(widget.documentID.isEmpty
              ? 'history_${widget.documentCount}'
              : widget.documentID)
          .set({
        "humanMessages": humanMessagesList,
        "botAIMessages": botAIMessagesList,
        "chatConversation": chatConversation,
      });
      print("****************************");
      print("Data saved to Firestore successfully!");
    } catch (e) {
      print("****************************");
      print("Error saving data to Firestore: $e");
    }
  }

  @override
  void initState() {
    getMessageFromFirestore();
    super.initState();
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
      _humanMessages.add(text);
      chatConversation += 'Human: $text.';
      _botAIMessages.add("...");
      _textEditingController.clear(); // Xóa văn bản trong ô nhập liệu
      _hasText = false; // Xóa văn bản và cập nhật biểu tượng thành thoại
    });
    String aiResponse = await _getAIResponse(text);

    for (int i = 0; i < aiResponse.length; i += 3) {
      await Future.delayed(const Duration(milliseconds: 50));
      String partialResponse = '${aiResponse.substring(0, i + 1)}▌';
      setState(() {
        if (_botAIMessages.isNotEmpty) {
          _botAIMessages[_botAIMessages.length - 1] = partialResponse;
        }
      });
    }

    // Cập nhật toàn bộ câu trả lời của bot AI sau khi hiển thị từng ký tự
    setState(() {
      _botAIMessages[_botAIMessages.length - 1] = aiResponse;
      chatConversation += '\nAi: $aiResponse';
    });
    if (_humanMessages.length == 1 && _botAIMessages.length == 1) {
      getChatTitlesFromFirestore();
      _createTitle();
    }
    saveMessageToFirestore();
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
            content: "$chatConversation\nAi: ",
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
                "hãy tạo tiêu đề với cuộc trò chuyện $chatConversation\ntiêu đề là tiếng việt, tối đa 20 ký tự \nTitle : ",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      // Trích xuất phản hồi từ response
      String aiResponse = chatCompletion.choices.first.message.content;
      setState(() {
        print(
            '***chat***_______________________ChatTitle1 :${chatTitle.length}');

        if (chatTitle.length >= widget.documentCount) {
          int startIndex = widget.documentCount - 1;
          chatTitle.removeRange(startIndex, chatTitle.length);
        }

        chatTitle.add(aiResponse);
      });

      await saveChatTitlesToFirestore();
      // print('***chat***_______________________ChatTitle1 :${chatTitle.length}');

      // for (int i = 0; i < chatTitle.length; i++)
      //   print('***chat***_______________________Title $i ${chatTitle[i]}');
    } catch (e) {
      chatTitle.add('Error Title');
      print("Error:_createTitle______________:$e");
    }
  }

  void _alertDeDeleteChatDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text('deleted chat history.'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      dlt = true;
                      setState(() {
                        _humanMessages.clear();
                        _botAIMessages.clear();
                      });
                      widget.onDeleteChatPressed();
                      Navigator.of(context).pop();
                      getMessageFromFirestore();
                    },
                    child: const Text(
                      'Oke',
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

  void _alertReSetChatDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Have reset chat history.'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onResetChatPressed();
                      Navigator.of(context).pop();
                      getMessageFromFirestore();
                    },
                    child: const Text(
                      'Oke',
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
                        widget.onHomePressed();
                        Navigator.of(context).pop();
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

    if (widget.documentID.isNotEmpty && widget.documentID != historyID) {
      // print('***chat***_______________________${widget.documentCount}');
      getMessageFromFirestore();
      setState(() {
        historyID = widget.documentID;
        titleText = true;
      });
    }

    // print("____________________________chat: ${widget.documentCount}")
    if (widget.resetChat &&
        _humanMessages.isNotEmpty &&
        _botAIMessages.isNotEmpty) {
      _alertReSetChatDialog();
    }

    if (widget.deleteChat && dlt) {
      _alertDeDeleteChatDialog();
      getMessageFromFirestore();
      dlt = false;
    }

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
                  humanMessages: _humanMessages,
                  botAIMessages: _botAIMessages,
                  flutterTts: _flutterTts,
                ),
              ),
              if (_botAIMessages.isNotEmpty)
                Container(
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      chatConversation = chatConversation.substring(
                          0,
                          chatConversation.length -
                              (_botAIMessages[_botAIMessages.length - 1]
                                      .length +
                                  _humanMessages[_humanMessages.length - 1]
                                      .length +
                                  13));

                      String humanMessEnd =
                          _humanMessages[_humanMessages.length - 1];
                      setState(() {
                        _botAIMessages.removeAt(_botAIMessages.length - 1);
                        _humanMessages.removeAt(_humanMessages.length - 1);
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
                              _handleSummitted(_textEditingController.text);
                              if (_humanMessages.length == 1 &&
                                  _botAIMessages.length == 1) {
                                widget
                                    .onSetSatePressed(); // cập nhật trangj thái
                                saveChatTitlesToFirestore();
                              }
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
