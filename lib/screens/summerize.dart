import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SummerizeScreen extends StatefulWidget {
  const SummerizeScreen({super.key, required this.apiKey});
  final String apiKey;
  @override
  State<StatefulWidget> createState() {
    return _SummerizeScreenState();
  }
}

class _SummerizeScreenState extends State<SummerizeScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  String _filePath = '';
  String _fileName = '';
  String _fileType = '';
  bool _isListening = false;
  String _lastWords = '';
  final stt.SpeechToText _speech = stt.SpeechToText();

  final FlutterTts _flutterTts = FlutterTts();

  bool _hasText = false;
  // bool _isLoadingAI = false;
  final List<String> _humanMessages = [];
  final List<String> _botAISummerize = [];

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

  // Future<void> uploadTxtFile(String text) async {
  //   try {
  //     final firebase_storage.Reference ref =
  //         firebase_storage.FirebaseStorage.instance.ref().child(_filePath);

  //     final firebase_storage.SettableMetadata metadata =
  //         firebase_storage.SettableMetadata(contentType: 'text/plain');

  //     final Uint8List data = Uint8List.fromList(text.codeUnits);
  //     final uploadTask = ref.putData(data, metadata);

  //     await uploadTask.whenComplete(() {
  //       print('TXT file uploaded.');
  //     });
  //   } catch (e) {
  //     print("Error uploading text file: $e");
  //   }
  // }

  void _pickFile() async {
    _humanMessages.clear();
    _botAISummerize.clear();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _filePath = file.path!;
        _fileName = file.name;
        _fileType = file.extension!;
      });
    } else {
      print('***summerize***__________User canceled the picker');
    }
  }

  void textLoaderFile(String text) async {
    try {
      if (_filePath.isNotEmpty) {
        TextLoader loader = TextLoader(_filePath);
        final documents = await loader.load();

        const textSplitter = CharacterTextSplitter(
          chunkSize: 800,
          chunkOverlap: 0,
        );
        final docChunks = textSplitter.splitDocuments(documents);

        final textsWithSources = docChunks.map(
          (e) {
            return e.copyWith(
              metadata: {...e.metadata, 'source': '${docChunks.indexOf(e)}-pl'},
            );
          },
        ).toList();
        final embeddings = OpenAIEmbeddings(apiKey: widget.apiKey);
        final docSearch = await MemoryVectorStore.fromDocuments(
          documents: textsWithSources,
          embeddings: embeddings,
        );

        final llm = ChatOpenAI(
          apiKey: widget.apiKey,
          model: 'gpt-3.5-turbo-0613',
          temperature: 0.7,
        );

        final qaChain = OpenAIQAWithSourcesChain(llm: llm);

        final docPrompt = PromptTemplate.fromTemplate(
          '''Hãy sử dụng nội dung của tôi đã cung cấp trong file text để trả lời các câu hỏi bằng tiếng Việt.\nLưu ý: Nếu không tìm thấy câu trả lời trong nội dung đã cung cấp, hãy thông báo "Thông tin không có trong tài liệu đã cung cung cấp ".
        .\ncontent: {page_content}\nSource: {source}
        ''',
        );

        final finalQAChain = StuffDocumentsChain(
          llmChain: qaChain,
          documentPrompt: docPrompt,
        );
        final retrievalQA = RetrievalQAChain(
          retriever: docSearch.asRetriever(),
          combineDocumentsChain: finalQAChain,
        );

        // print('***summerize***______________________question: $text');
        // setState(() {
        //   _isLoadingAI = true;
        // });
        final res = await retrievalQA(text);
        // setState(() {
        //   _isLoadingAI = false;
        // });
        // ignore: avoid_print

        String aiResponse = res['result'].toString();

        for (int i = 0; i < aiResponse.length; i += 3) {
          await Future.delayed(const Duration(milliseconds: 50));
          String partialResponse = '${aiResponse.substring(0, i + 1)}▌';
          setState(() {
            _botAISummerize[_botAISummerize.length - 1] = partialResponse;
          });
        }

        // Cập nhật toàn bộ câu trả lời của bot AI sau khi hiển thị từng ký tự
        setState(() {
          _botAISummerize[_botAISummerize.length - 1] = aiResponse;
        });
      }
    } catch (e) {
      print("______________________________");
      if (e.toString().contains('statusCode: 429')) {
        setState(() {
          _botAISummerize.add(
              'Lỗi khi tóm tắt file , hãy thử lại... lỗi statusCode: 429 ');
        });
      } else {
        setState(() {
          _botAISummerize.add('Lỗi khi tóm tắt file , hãy thử lại');
        });
      }
      print("Error loading text file: $e");
      print("Error loading text file: $e");
      print("Error loading text file: $e");
      print("Error loading text file: $e");
      print("Error loading text file: $e");
    }
  }

  void _submitForm(String text) async {
    setState(() {
      _humanMessages.add(text);
      _botAISummerize.add('');
      _textEditingController.clear(); // Xóa văn bản trong ô nhập liệu
      _hasText = false; // Xóa văn bản và cập nhật biểu tượng thành thoại
    });

    // ignore: await_only_futures
    textLoaderFile(text);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void textToSpeech(String text) async {
    await langdetect.initLangDetect();
    await _flutterTts.setLanguage(langdetect.detect(text));
    await _flutterTts.setVolume(0.5);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _pickFile();
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.drive_folder_upload_rounded,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Choose a file.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (_filePath.isNotEmpty)
                    const Icon(Icons.keyboard_double_arrow_right_rounded),
                  const SizedBox(width: 20),
                  if (_fileType == 'pdf')
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 40,
                      color: Colors.red,
                    ),
                  if (_fileType == 'txt')
                    Image.asset(
                      'assets/images/logo_txt.png',
                      width: 30,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    _fileName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: ListView.builder(
                  // reverse: true,
                  itemCount: _humanMessages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 30),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(18),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  _humanMessages[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor: Color.fromARGB(255, 18, 6, 50),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Color.fromARGB(255, 105, 133, 231),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage('assets/images/chatbot.png'),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  _botAISummerize[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  textToSpeech(
                                      _botAISummerize.length - index - 1 >= 0
                                          ? _botAISummerize[
                                              (_botAISummerize.length -
                                                  index -
                                                  1)]
                                          : '');
                                },
                                icon: const Icon(
                                  Icons.volume_up,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_filePath.isNotEmpty)
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
                                _submitForm(_textEditingController.text);
                              }
                            : () {
                                _listen();
                              },
                        icon: _hasText
                            ? const Icon(Icons.send, color: Colors.black)
                            : const Icon(Icons.mic, color: Colors.black),
                      ),
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
