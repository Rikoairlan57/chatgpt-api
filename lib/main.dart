import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:chat_gpt_sdk/src/model/model_data.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ChatGPT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var results = "results...";
  late ChatGPT openAI;
  TextEditingController textEditingController = TextEditingController();

  List<ChatMessage> messages = [];
  ChatUser user = ChatUser(
    id: "1",
    firstName: "You",
  );
  ChatUser openGpt = ChatUser(
    id: "2",
    firstName: "OPENAI",
    lastName: "CHATGPT",
  );

  late TextToSpeech tts;
  bool isTTS = false;
  final SpeechToText _speechToText = SpeechToText();
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    openAI = ChatGPT.instance.builder(
      "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",
      baseOption: HttpSetup(receiveTimeout: 16000),
    );

    tts = TextToSpeech();
    _initSpeech();
  }

  void _initSpeech() async {
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        textEditingController.text = result.recognizedWords;
      });
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatGPT"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              setState(
                () {
                  if (isTTS) {
                    isTTS = false;
                    tts.stop();
                  } else {
                    isTTS = true;
                  }
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isTTS ? Icons.record_voice_over : Icons.voice_over_off_sharp,
              ),
            ),
          )
        ],
        leading: InkWell(
          child: const Icon(Icons.light_mode),
          onTap: () {
            setState(() {
              if (isDark) {
                isDark = false;
              } else {
                isDark = true;
              }
            });
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
            invertColors: isDark,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: DashChat(
                  currentUser: user,
                  onSend: (ChatMessage m) {
                    setState(
                      () {
                        messages.insert(0, m);
                      },
                    );
                  },
                  messages: messages,
                  readOnly: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: TextField(
                            controller: textEditingController,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "type anything here.."),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.blue),
                      child: const Icon(Icons.mic),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.blue),
                      child: const Icon(Icons.send),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
