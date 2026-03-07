import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathView extends StatelessWidget {

  final String text;
  final bool isUser;

  const MathView({
    super.key,
    required this.text,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {

    final color = isUser ? Colors.white : Colors.black;

    // Split text using $$ for latex blocks
    List<String> parts = text.split(r"$$");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(parts.length, (i) {

        // Even index → normal text
        if (i % 2 == 0) {
          return Text(
            parts[i],
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          );
        }

        // Odd index → latex
        try {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Math.tex(
              parts[i],
              textStyle: TextStyle(
                fontSize: 20,
                color: color,
              ),
            ),
          );
        } catch (e) {
          return Text(
            parts[i],
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          );
        }

      }),
    );
  }
}