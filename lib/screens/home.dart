import 'package:chatbot_app/providers/api_key_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.onChatPressed,
  });

  final VoidCallback onChatPressed;

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var _enteredAPIKey = '';
  final _formKey = GlobalKey<FormState>();

  void _goToChatScreen() {
    widget.onChatPressed();
  }

  Future<void> _getAPIKeyFromFirestore() async {
    try {
      // Lấy API key từ Firestore
      var collection = FirebaseFirestore.instance.collection('APIKey');
      var snapshot = await collection
          .doc('kZZJdmsZk03CZ80J8Sj0')
          .get(); // Chỉnh sửa kiểu của biến snapshot
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        String apiKey = data['apikey'];
        ref.read(apiKeyProvider.notifier).update((state) => apiKey);
      } else {
        ref.read(apiKeyProvider.notifier).update((state) => null);
      }
    } catch (e) {
      print("Error fetching API key: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getAPIKeyFromFirestore(); // Gọi phương thức lấy API key
  }

  Future<bool> _checkAPIKey(String apiKey) async {
    try {
      // Đặt API key bằng cách gọi setter
      OpenAI.apiKey = apiKey;
      // OpenAIChatCompletionModel chatCompletion =
      await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          const OpenAIChatCompletionChoiceMessageModel(
            content: "hello",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      return true;
    } catch (e) {
      // Nếu yêu cầu không thành công, API key không hợp lệ
      return false;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Kiểm tra API key bằng cách gọi API OpenAI
      _checkAPIKey(_enteredAPIKey).then((isValid) {
        if (isValid) {
          // Lưu trữ API key vào Firestore
          CollectionReference collection =
              FirebaseFirestore.instance.collection('APIKey');
          DocumentReference document = collection.doc('kZZJdmsZk03CZ80J8Sj0');
          document.update({'apikey': _enteredAPIKey});

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('API Key Confirmation'),
              content: const Text('Your API key is valid and saved!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng hộp thoại
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // API key không hợp lệ
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('API Key Error'),
              content:
                  const Text('Invalid API key. Please check and try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _goToChatScreen();
                    // Đóng hộp thoại
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 105, 55, 230),
              Color.fromARGB(255, 238, 99, 106),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              'assets/images/chatbot.png',
              width: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'API key',
                            border:
                                OutlineInputBorder(), // Khung viền cho TextFormField
                            filled: true, // Đổ màu nền cho TextFormField
                            fillColor:
                                Colors.white, // Màu nền cho TextFormField
                            hintText:
                                'Enter your API key', // Gợi ý khi TextFormField trống
                            hintStyle: TextStyle(
                                color: Colors.grey), // Màu chữ cho gợi ý
                            prefixIcon:
                                Icon(Icons.vpn_key), // Icon trước TextFormField
                          ),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          initialValue:
                              ref.watch(apiKeyProvider.notifier).state,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an API key';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredAPIKey = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.amber), // Màu viền
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    foregroundColor:
                                        Colors.blueAccent // Padding
                                    ),
                                onPressed: _submitForm,
                                child: const Text('User API Key'),
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
