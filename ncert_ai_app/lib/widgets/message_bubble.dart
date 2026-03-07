import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/math_view.dart';
import '../widgets/graph_view.dart';

class MessageBubble extends StatelessWidget {

  final bool isUser;
  final String text;

  const MessageBubble({
    super.key,
    required this.isUser,
    required this.text,
  });

  // single TTS instance
  static final FlutterTts tts = FlutterTts();

  Future speak(String msg) async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
    await tts.speak(msg);
  }

  Future stopSpeak() async {
    await tts.stop();
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(

        margin: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 10,
        ),

        padding: const EdgeInsets.all(14),

        constraints: const BoxConstraints(
          maxWidth: 320,
        ),

        decoration: BoxDecoration(

          color: isUser
              ? Colors.blue
              : Colors.grey.shade300,

          borderRadius: BorderRadius.circular(14),

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [

            // -------- TEXT / MATH --------

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 300,
              ),
              child: MathView(
                text: text,
                isUser: isUser,
              ),
            ),

            const SizedBox(height: 10),

            // -------- GRAPH --------

            if (text.toLowerCase().contains("plot"))

              SizedBox(
                height: 200,
                child: GraphView(
                  text: text,
                ),
              ),

            const SizedBox(height: 6),

            // -------- SPEAK BUTTONS --------

            if (!isUser)

              Row(

                mainAxisAlignment: MainAxisAlignment.end,

                children: [

                  IconButton(

                    icon: const Icon(
                      Icons.volume_up,
                      size: 18,
                    ),

                    onPressed: (){
                      speak(text);
                    },

                  ),

                  IconButton(

                    icon: const Icon(
                      Icons.stop,
                      size: 18,
                    ),

                    onPressed: (){
                      stopSpeak();
                    },

                  )

                ],

              )

          ],

        ),

      ),

    );

  }

}