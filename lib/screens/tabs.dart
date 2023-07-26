import 'package:chatbot_app/screens/chat.dart';
import 'package:chatbot_app/screens/home.dart';
import 'package:chatbot_app/screens/summerize.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  var activePageTitle = 'chat';
  int _selectPageIndex = 0;
  bool _selectHome = true;

  void _selectPage(int index) {
    setState(() {
      _selectPageIndex = index;
      _selectHome = false;
    });
  }

  void _setSelectHome() {
    setState(() {
      _selectHome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const ChatScreen();

    if (_selectPageIndex == 1) {
      activePageTitle = 'summerize';
      activePage = const SummerizeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.home,
          ),
          onPressed: _setSelectHome,
        ),
        title: const Text(
          'Flutter ChatGPT',
          style: TextStyle(
            color: Colors.white, // Màu chữ cho tiêu đề AppBar
            fontSize: 24, // Kích thước font chữ cho tiêu đề AppBar
            fontWeight:
                FontWeight.bold, // Độ đậm của font chữ cho tiêu đề AppBar
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 129, 94, 215),
      ),
      body: _selectHome ? const HomeScreen() : activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectPageIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.summarize), label: 'Summerize'),
        ],
      ),
    );
  }
}
