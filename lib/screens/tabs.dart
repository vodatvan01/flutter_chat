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
  String _documentID = '';
  bool isValidAPIKey = false;
  bool resetChat = false;
  bool deleteChat = false;
  bool onPressIndex = false;
  final List<String> chatTitle = [];
  int indexChatTitle = 0;
  bool _isLoading = true;
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _getAPIKeyFromFirestore().then((apiKey) {
      setState(() {
        _apiKey = apiKey;
        _isLoading = false;
      });
    });
    getDocumentCount();
    getChatTitlesFromFirestore();
  }

  Future<void> getDocumentCount() async {
    try {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("Chat_history");
      QuerySnapshot querySnapshot = await collectionRef.get();
      setState(() {
        _documentCount = querySnapshot.size;
      });
    } catch (e) {
      print("Error getting document count: $e");
      setState(() {
        _documentCount = 0;
      });
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
      List<String> humanMessagesList = [];
      List<String> botAIMessagesList = [];
      // String chatConver =
      // Thêm dữ liệu vào Firestore
      await FirebaseFirestore.instance
          .collection("Chat_history")
          .doc(_documentID)
          .set({
        "humanMessages": humanMessagesList,
        "botAIMessages": botAIMessagesList,
        "chatConversation": '',
      });
      // print("****************************");
      // print("Data saved to Firestore successfully!");
    } catch (e) {
      // ignore: avoid_print
      print("****************************");
      // ignore: avoid_print
      print("Error saving data to Firestore: $e");
    }
  }

  void deleteHistoryChat() async {
    try {
      await FirebaseFirestore.instance
          .collection('Chat_history')
          .doc(_documentID)
          .delete();
      print('Document deleted successfully.');
    } catch (e) {
      print('Error deleting document: $e');
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

  void _resetChat() {
    setState(() {
      resetChat = false;
    });
  }

  void _deleteChat() {
    setState(() {
      deleteChat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else {
      Widget activePage = ChatScreen(
        apiKey: _apiKey,
        documentCount: _documentCount,
        documentID: _documentID,
        isValidAPIKey: isValidAPIKey,
        onHomePressed: _goToHomeScreen,
        resetChat: resetChat,
        onResetChatPressed: _resetChat,
        deleteChat: deleteChat,
        onDeleteChatPressed: _deleteChat,
      );

      if (_selectPageIndex == 1) {
        activePageTitle = 'Summerize';
        activePage = SummerizeScreen(
          apiKey: _apiKey,
        );
      } else {
        activePageTitle = 'ChatBot';
      }

      // print("____________________________Tabschat: $_documentID");
      // print("____________________________lenchatTitle: ${chatTitle.length}");
      // getChatTitlesFromFirestore();
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
                          onSelected: (value) async {
                            // Xử lý sự kiện khi một mục trong menu được chọn
                            await getChatTitlesFromFirestore();
                            if (value == 'Rename Chat') {
                              //
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String newChatName =
                                      ""; // Biến lưu tên chat mới

                                  return AlertDialog(
                                    title: const Text('Rename Chat'),
                                    content: TextField(
                                      onChanged: (value) {
                                        newChatName = value
                                            .trim(); // Cập nhật giá trị tên chat mới
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'Enter new chat name'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          if (newChatName.isNotEmpty) {
                                            setState(() {
                                              chatTitle[indexChatTitle] =
                                                  newChatName;
                                            });
                                            await saveChatTitlesToFirestore();
                                            await getChatTitlesFromFirestore();
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          } else {
                                            // Hiển thị thông báo lỗi bằng SnackBar
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please enter new chat name'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } // Đóng AlertDialog
                                        },
                                        child: const Text('Save'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Đóng AlertDialog
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (value == 'Reset Chat') {
                              setState(() async {
                                resetChat = true;
                                if (_documentID.isEmpty) {
                                  _documentID = 'history_$_documentCount';
                                }
                                await saveMessageToFirestore();
                                await getDocumentCount();
                                await getChatTitlesFromFirestore();
                                resetChat = true;
                              });
                            } else if (value == 'Delete Chat') {
                              if (_documentID.isEmpty) {
                                setState(() {
                                  _documentID = 'history_$_documentCount';
                                });
                              }
                              deleteHistoryChat();
                              getDocumentCount();
                              getChatTitlesFromFirestore();
                              setState(() {
                                chatTitle.removeAt(indexChatTitle);
                              });
                              saveChatTitlesToFirestore();
                              setState(() {
                                deleteChat = true;
                              });
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
          documentCount: _documentCount,
          isValidAPIKey: isValidAPIKey,
          selectPageIndex: _selectPageIndex,
          onHistoryPressed: (value, indexTitle) async {
            await getDocumentCount();
            await getChatTitlesFromFirestore();
            _goToChatScreen();
            setState(() {
              _documentID = value;
              indexChatTitle = indexTitle;
              onPressIndex = true;
            });
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
