import 'package:chatbot_app/Widgets/main_drawer.dart';
import 'package:chatbot_app/screens/chat.dart';
import 'package:chatbot_app/screens/home.dart';
import 'package:chatbot_app/screens/summerize.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  var activePageTitle = 'ChatBot';
  int _selectPageIndex = 0;
  bool _selectHome = true;
  int _documentCount = 0;
  bool isValidAPIKey = false;
  bool resetChat = false;
  bool deleteChat = false;
  bool onPressIndex = false;

  bool _isLoading = true;
  String _apiKey = '';
  List<dynamic> chatList = [];
  Map<String, dynamic> newChat = {};
  List<String> humanMessages = [];
  List<String> botAIMessages = [];
  List<String> chatTitle = [];
  String _chatTitle = '';
  String chatConversation = '';

  @override
  void initState() {
    super.initState();
    _getAPIKeyFromFirestore().then((apiKey) {
      setState(() {
        _apiKey = apiKey;
        _isLoading = false;
      });
    });
    getChatHistoryData();
  }

  void saveToFirestore() async {
    try {
      Map<String, dynamic> newChat = {
        'humanMessages': humanMessages,
        'botAIMessages': botAIMessages,
        'chatconversation': chatConversation,
        'ChatTitle': _chatTitle,
      };

      chatList[_documentCount - 1] = newChat;

      await FirebaseFirestore.instance
          .collection("Memory")
          .doc('ChatHistory')
          .set({'ListChatHistory': chatList});

      print('Dữ liệu đã được lưu vào Firestore thành công.');
    } catch (e) {
      print('Lỗi khi lưu dữ liệu vào Firestore: $e');
    }
  }

  void deleteToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection("Memory")
          .doc('ChatHistory')
          .set({'ListChatHistory': chatList});

      print('Dữ liệu đã được xóa vào Firestore thành công.');
    } catch (e) {
      print('Lỗi khi xóa dữ liệu vào Firestore: $e');
    }
  }

  Future<void> getChatHistoryData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Memory')
          .doc('ChatHistory')
          .get();

      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      // Kiểm tra dữ liệu không null và là kiểu List<Map<String, dynamic>>
      if (data != null) {
        setState(() {
          chatList = data['ListChatHistory'] as List<dynamic>;
          _documentCount = chatList.length;
          chatTitle.clear();
          for (var chat in chatList) {
            chatTitle.add(chat['ChatTitle']);
          }
        });
      } else {
        print("Tài liệu không tồn tại.");
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu từ Firestore: $e');
    }
  }

// chưa xử lý phần Rename (lỗi ở document count (_documentCount))
  Future<void> getChatHistoryData1() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Memory')
          .doc('ChatHistory')
          .get();

      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      // Kiểm tra dữ liệu không null và là kiểu List<Map<String, dynamic>>
      if (data != null) {
        setState(() {
          chatList = data['ListChatHistory'] as List<dynamic>;
          chatTitle.clear();
          for (var chat in chatList) {
            chatTitle.add(chat['ChatTitle']);
          }
        });
      } else {
        print("Tài liệu không tồn tại.");
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu từ Firestore: $e');
    }
  }

  Future<String> _getAPIKeyFromFirestore() async {
    try {
      // Lấy API key từ Firestore
      var collection = FirebaseFirestore.instance.collection('APIKey');
      var snapshot = await collection.doc('OpenAPIKey').get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        String apiKey = data['apikey'];
        return apiKey;
      } else {
        return '';
      }
    } catch (e) {
      print("Error fetching API key: $e");
      return '';
    }
  }

  void showRenameChatDialog() async {
    String newChatName = ""; // Biến lưu tên chat mới

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Chat'),
          content: TextField(
            onChanged: (value) {
              newChatName = value.trim(); // Cập nhật giá trị tên chat mới
            },
            decoration: const InputDecoration(
              hintText: 'Enter new chat name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newChatName.isNotEmpty) {
                  setState(() {
                    _chatTitle = newChatName;
                  });
                } else {
                  setState(() {
                    _chatTitle = 'New chat';
                  });
                }
                Navigator.pop(context);
                print('_________________________$_documentCount');
                saveToFirestore();
                getChatHistoryData1();

                // Đóng AlertDialog
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng AlertDialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void alertReSetChatDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content:
                const Text('Are you sure you want to reset the conversation ?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        botAIMessages.clear();
                        humanMessages.clear();
                        chatConversation = '';
                        _chatTitle = chatList[_documentCount - 1]['ChatTitle']
                            .toString();
                        saveToFirestore();
                      });

                      Navigator.of(context).pop();
                    },
                    child: const Text('Reset'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  void alertDeDeleteChatDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning', textAlign: TextAlign.center),
            content: const Text('Are you sure you want to delete the chat?',
                textAlign: TextAlign.center),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      print(
                          '___________${_documentCount - 1} _________${chatList.length}');
                      setState(() {
                        chatList.removeAt(_documentCount - 1);
                      });
                      deleteToFirestore();
                      _newChat();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectPageIndex = index;
      _selectHome = false;
    });
  }

  void _goToHomeScreen() {
    setState(() {
      _getAPIKeyFromFirestore().then((apiKey) {
        _apiKey = apiKey;
      });
      _selectHome = true;
      isValidAPIKey = false;
    });
  }

  void _goToChatScreen() {
    setState(() {
      _selectPageIndex = 0;
      _selectHome = false;
      isValidAPIKey = true;
    });
  }

  void historyChat(int index) {
    setState(() {
      _documentCount = index;
      chatConversation = chatList[index - 1]['chatconversation'].toString();
      humanMessages = chatList[index - 1]['humanMessages']
          .map((element) {
            if (element is String) {
              return element;
            }
            return element.toString();
          })
          .whereType<String>()
          .toList();

      botAIMessages = chatList[index - 1]['botAIMessages']
          .map((element) {
            if (element is String) {
              return element;
            }
            return element.toString();
          })
          .whereType<String>()
          .toList();
    });
  }

  void _newChat() async {
    await getChatHistoryData();
    setState(() {
      humanMessages.clear();
      botAIMessages.clear();
      chatConversation = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else {
      Widget activePage = ChatScreen(
        apiKey: _apiKey,
        isValidAPIKey: isValidAPIKey,
        chatList: chatList,
        documentCount: _documentCount,
        botAIMessages: botAIMessages,
        humanMessages: humanMessages,
        chatConversation: chatConversation,
        onHomePressed: _goToHomeScreen,
      );

      if (_selectPageIndex == 1) {
        activePageTitle = 'Summerize';
        activePage = SummerizeScreen(
          apiKey: _apiKey,
        );
      } else {
        activePageTitle = 'ChatBot';
      }

      return Scaffold(
        appBar: AppBar(
            title: Text(
              _selectHome ? 'Home' : activePageTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 129, 94, 215),
            actions: _selectHome
                ? []
                : _selectPageIndex == 0
                    ? <Widget>[
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Rename Chat') {
                              showRenameChatDialog();
                            } else if (value == 'Reset Chat') {
                              alertReSetChatDialog();
                            } else if (value == 'Delete Chat') {
                              alertDeDeleteChatDialog();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'Rename Chat',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_square),
                                    SizedBox(width: 5),
                                    Text('Rename Chat')
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Reset Chat',
                                child: Row(
                                  children: [
                                    Icon(Icons.auto_delete_outlined),
                                    SizedBox(width: 5),
                                    Text('Reset Chat')
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Delete Chat',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete),
                                    SizedBox(width: 5),
                                    Text('Delete Chat')
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ]
                    : []),
        drawer: MainDrawer(
          chatTitle: chatTitle,
          onHomePressed: _goToHomeScreen,
          isValidAPIKey: isValidAPIKey,
          selectPageIndex: _selectPageIndex,
          onNewChatPressed: _newChat,
          onHistoryPressed: (indexTitle) {
            historyChat(indexTitle);
            print('___________$_documentCount');
          },
        ),
        body: _selectHome
            ? HomeScreen(
                onChatPressed: _goToChatScreen,
                apiKey: _apiKey,
              )
            : activePage,
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectPageIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.summarize), label: 'Summerize'),
          ],
        ),
      );
    }
  }
}
