import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    super.key,
    required this.onHomePressed,
    required this.documentCount,
    required this.onHistoryPressed,
    required this.isValidAPIKey,
    required this.selectPageIndex,
    required this.chatTitle,
  });

  final VoidCallback onHomePressed;
  final void Function(String documentID, int index) onHistoryPressed;
  final int documentCount;
  final bool isValidAPIKey;
  final int selectPageIndex;
  final List<String> chatTitle;

  @override
  State<StatefulWidget> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  int _documentCount = 0;
  void goToHomeScreen(BuildContext context) {
    widget.onHomePressed();
    Navigator.pop(context);
  }

  @override
  void initState() {
    _documentCount = widget.documentCount;
    super.initState();
  }

  Future<void> saveMessageToFirestore(String newChat) async {
    try {
      // ignore: unused_local_variable
      List<String> humanMessagesList = [];
      // ignore: unused_local_variable
      List<String> botAIMessagesList = [];
      // Thêm dữ liệu vào Firestore
      await FirebaseFirestore.instance
          .collection("Chat_history")
          .doc(newChat)
          .set({
        "humanMessages": humanMessagesList,
        "botAIMessages": botAIMessagesList,
        "chatConversation": '',
      });
      // print("****************************");
      // print("Data saved to Firestore successfully!");
    } catch (e) {
      print("****************************");
      print("Error saving data to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("_______________________________ maindrawer: $_documentCount");
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                ),
                const SizedBox(width: 18),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 34,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Home',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20),
            ),
            onTap: () {
              goToHomeScreen(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 34,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 20),
            ),
            onTap: () {},
          ),
          const Divider(
            height: 2,
          ),
          if (widget.isValidAPIKey && widget.selectPageIndex == 0)
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: () {
                saveMessageToFirestore('history_$_documentCount');
                widget.onHistoryPressed(
                    'history_$_documentCount', _documentCount);
                Navigator.pop(context);
              },
            ),
          if (widget.isValidAPIKey && widget.selectPageIndex == 0)
            const Divider(
              height: 2,
            ),
          if (widget.isValidAPIKey && widget.selectPageIndex == 0)
            Expanded(
              child: ListView.builder(
                itemCount: widget.chatTitle.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        widget.chatTitle[widget.chatTitle.length - index - 1]),
                    onTap: () {
                      widget.onHistoryPressed(
                          'history_${_documentCount - index - 1}',
                          widget.chatTitle.length - index - 1);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
