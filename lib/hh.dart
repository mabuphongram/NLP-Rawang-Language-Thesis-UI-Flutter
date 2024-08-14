import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MyAnimatedText extends StatefulWidget {
  @override
  _MyAnimatedTextState createState() => _MyAnimatedTextState();
}

class _MyAnimatedTextState extends State<MyAnimatedText> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 4)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                'Hybrid Approach To Rawang Language Word Segmentation using Part-of-Speech Tagging',
                textStyle: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
                colors: [
                  Colors.purple,
                  Colors.blue,
                  Colors.yellow,
                  Colors.red,
                ],
              ),
            ],
            isRepeatingAnimation: true,
          );
        } else {
          return Container(); // Or any loading indicator if needed
        }
      },
    );
  }
}
