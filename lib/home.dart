import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<List<dynamic>> _results = [];
  List<String> _stepsResults = ["", "", "", "", "", ""]; // Store results for each step

  // bool _isPunctuationRemoved = false; // Track if punctuation has been removed

  final List<String> specialCharacters = [
    // Punctuation Marks
    ',', ':', ';', '!', "'", '"', '-', '_', '(', ')', '[', ']', '{', '}', '/', '\\', '|', '#', '%', '@', '&', '*', '+', '=', '<', '>', '^', '~', '`',
    // Currency Symbols
    '\$', '€', '£', '¥', '₹', '¢', '₽', '₩', '₪', '₫', '₭', '₦',
    // Mathematical Symbols
    '+', '-', '*', '/', '=', '<', '>', '±', '×', '÷', '≠', '≈', '≤', '≥', '%', '√', '∞', '∑', '∏', '∫', '∆', '∂', '∇', '∈', '∉', '∩', '∪',
    // Other Symbols
    '©', '®', '™', '§', '¶', '°', '′', '″', 'µ', '†', '‡', '‽', '⁂'
  ];

  Future<void> _predictPOS() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': _stepsResults[4]}),
      );

      if (response.statusCode == 200) {
        print('Response is ${response.body}');
        setState(() {
          _results = List<List<dynamic>>.from(json.decode(response.body));
          _stepsResults[5] = _results.map((result) => 'Words: ${result.join(', ')}').join('\n');
        });
      } else {
        print('Failed to load predictions: ${response.statusCode}');
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print('Error during request: $e');
      // Handle error in UI or log it
    }
  }

  void _removeSpecialCharacters() {
    setState(() {
      String text = _stepsResults[0];
      for (String char in specialCharacters) {
        text = text.replaceAll(char, '');
      }
      _stepsResults[1] = text;
    });
  }

  void _convertToLowerCase() {
    setState(() {
      _stepsResults[2] = _stepsResults[1].toLowerCase();
    });
  }

  void _removePunctuations() {
    setState(() {
      _stepsResults[3] = _stepsResults[2].replaceAll('.', '').replaceAll('?', '');
      // _isPunctuationRemoved = true; // Mark punctuation as removed
    });
  }

  void _segmentWords() {
    setState(() {
      // Directly use the result from _removePunctuations
      _stepsResults[4] = _stepsResults[3];
    });
  }

  void _segmentSentences() {
    setState(() {
      String text = _controller.text;
      _stepsResults[0] = text.split(RegExp(r'(?<=[.?\n])')).where((s) => s.trim().isNotEmpty).map((s) => s.trim()).join('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 300),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Image.asset('assets/images/rawang1.png'),
                // Image.asset('assets/images/manaw.png'),
                Image.asset('assets/images/rawang2.png'),
                          ],),
              ],
            ),
            Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Image.asset('assets/images/hat.png',width: 100,),
                Text('Hybrid Approach to Rawang Language Word Segmentation Using Part-of-Speech Tagging ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),)
              ],),
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Enter text'),
              ),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: ElevatedButton(
                  onPressed: _segmentSentences,
                  child: Text('Segment Sentences'),
                ),
              ),
              if (_stepsResults[0].isNotEmpty)
                Text(' ${_stepsResults[0]}'),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: ElevatedButton(
                  onPressed: _removeSpecialCharacters,
                  child: Text('Remove Special Characters'),
                ),
              ),
              if (_stepsResults[1].isNotEmpty)
                Text(' ${_stepsResults[1]}'),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: ElevatedButton(
                  onPressed: _convertToLowerCase,
                  child: Text('Convert to Lowercase'),
                ),
              ),
              if (_stepsResults[2].isNotEmpty)
                Text(' ${_stepsResults[2]}'),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: ElevatedButton(
                  onPressed: _removePunctuations,
                  child: Text('Remove Punctuations'),
                ),
              ),
              if (_stepsResults[3].isNotEmpty)
                Text(' ${_stepsResults[3]}'),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: ElevatedButton(
                  onPressed: _segmentWords,
                  child: Text('Segment Words'),
                ),
              ),
              if (_stepsResults[4].isNotEmpty)
                Text(' ${_stepsResults[4]}'),
              SizedBox(height: 20),
              Container(
                width: 250,
                child: ElevatedButton(
                  onPressed: _predictPOS,
                  child: Text('Predict POS Tags'),
                ),
              ),
              if (_stepsResults[5].isNotEmpty)
                Container(
                  height: 200, // You can set a fixed height
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${index+1} ${result.join(', ')}',style: TextStyle(letterSpacing: 1,wordSpacing: 1.5),).animate().fade(duration: 2000.ms,delay: 500.ms).slideY(curve: Curves.easeIn),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
          
          ]
        ),
      ),
    );
  }
}
