import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Example',
      home: FirestoreExample(),
    );
  }
}

class FirestoreExample extends StatefulWidget {
  @override
  _FirestoreExampleState createState() => _FirestoreExampleState();
}

class _FirestoreExampleState extends State<FirestoreExample> {
  // Khởi tạo một thể hiện của Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dữ liệu mẫu để lưu vào Firestore
  List<Map<String, dynamic>> chatList = [
    {
      'human': ['Hello', 'How are you?'],
      'botAi': ['Hi there!', 'I am fine, thank you.'],
      'chatconversation': 'A simple conversation between human and bot.',
      'ChatTitle': 'Simple Chat'
    },
    {
      'human': ['Hi', 'What\'s your name?'],
      'botAi': ['Greetings!', 'I am an AI bot.'],
      'chatconversation': 'Introduction and greeting.',
      'ChatTitle': 'Introduction Chat'
    },
    // Các mục khác có thể được thêm vào danh sách tương tự
  ];

  // Phương thức để lưu dữ liệu vào Firestore
  void saveToFirestore() async {
    try {
      // Lấy tham chiếu tới collection 'Memory' và document 'History'
      DocumentReference docRef = _firestore.collection('Memory').doc('History');

      // Lưu dữ liệu vào document
      await docRef.set({
        'chatList': chatList,
      });

      print('Dữ liệu đã được lưu vào Firestore thành công.');
    } catch (e) {
      print('Lỗi khi lưu dữ liệu vào Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: saveToFirestore,
              child: Text('Lưu dữ liệu vào Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
