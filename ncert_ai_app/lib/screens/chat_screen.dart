import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lottie/lottie.dart';

import '../screens/profile_screen.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {

  final String token;
  final String email;

  const ChatScreen({
    super.key,
    required this.token,
    required this.email
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController controller = TextEditingController();
  final ScrollController scroll = ScrollController();

  List<Map<String,dynamic>> messages = [];

  bool loading = false;

  static const api = "http://192.168.29.20:8000";

  SpeechToText speech = SpeechToText();

  // =========================
  // ASK AI
  // =========================

  Future<void> askAI(String question) async {

    if(question.trim().isEmpty) return;

    setState(() {

      messages.add({
        "role":"user",
        "text":question
      });

      loading = true;

    });

    controller.clear();
    scrollToBottom();

    try{

      var res = await http.post(

        Uri.parse("$api/ask"),

        headers:{
          "Content-Type":"application/json",
          "Authorization":"Bearer ${widget.token}"
        },

        body: jsonEncode({
          "messages":[
            {"role":"user","content":question}
          ]
        }),

      );

      var data = jsonDecode(res.body);

      String answer =
          data["answer"] ?? "Sorry, no answer found.";

      setState(() {

        loading = false;

        messages.add({
          "role":"ai",
          "text":answer
        });

      });

      scrollToBottom();

    }catch(e){

      setState(() {

        loading = false;

        messages.add({
          "role":"ai",
          "text":"Server error"
        });

      });

    }

  }

  // =========================
  // SCROLL
  // =========================

  void scrollToBottom(){

    Future.delayed(const Duration(milliseconds:300),(){

      if(scroll.hasClients){

        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds:300),
          curve: Curves.easeOut,
        );

      }

    });

  }

  // =========================
  // VOICE INPUT
  // =========================

  void startListening() async{

    await speech.stop();

    bool available = await speech.initialize();

    if(available){

      speech.listen(onResult:(result){

        setState(() {

          controller.text =
              result.recognizedWords;

        });

      });

    }

  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        title: const Text("AI Tutor"),

        actions: [

          IconButton(

            icon: const Icon(Icons.person),

            onPressed:(){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_)=>ProfileScreen(
                    email: widget.email
                  ),

                ),

              );

            },

          )

        ],

      ),

      body: Stack(

        children: [

          // ---------- BACKGROUND ----------

          Container(

            decoration: const BoxDecoration(

              image: DecorationImage(

                image: AssetImage("assets/chat_bg.jpg"),

                fit: BoxFit.cover

              ),

            ),

          ),

          Column(

            children: [

              // ---------- CHAT LIST ----------

              Expanded(

                child: ListView.builder
                (

                  controller: scroll,

                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) 
                  {
                    bool isUser = messages[index]["role"] == "user";


                    

                    return MessageBubble(
                      text: messages[index]["text"],
                      isUser: isUser,
                    );

                  },

                ),

              ),

              // ---------- AI THINKING ----------

              if(loading)

              Padding(

                padding: const EdgeInsets.all(10),

                child: Lottie.asset(

                  "assets/animations/ai_thinking.json",

                  width:200,
                  height:200

                ),

              ),

              // ---------- INPUT BAR ----------

              Container(

                padding: const EdgeInsets.all(10),

                decoration: const BoxDecoration(

                  color: Colors.white,

                  border: Border(
                    top: BorderSide(color: Colors.black12)
                  )

                ),

                child: Row(

                  children: [

                    IconButton(

                      icon: const Icon(Icons.mic),

                      onPressed: startListening,

                    ),

                    Expanded(

                      child: TextField(

                        controller: controller,

                        decoration: InputDecoration(

                          hintText: "Ask your question...",

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(30)
                          ),

                          contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal:20
                              ),

                        ),

                      ),

                    ),

                    const SizedBox(width:8),

                    CircleAvatar(

                      radius:24,

                      backgroundColor: Colors.blue,

                      child: IconButton(

                        icon: const Icon(
                          Icons.send,
                          color:Colors.white
                        ),

                        onPressed: loading
                        ? null
                        : (){
                            askAI(controller.text);
                          },

                      ),

                    )

                  ],

                ),

              )

            ],

          )

        ],

      ),

    );

  }

}