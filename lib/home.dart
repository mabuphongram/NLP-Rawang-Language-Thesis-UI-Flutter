import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController segment_sentence_controller;
  late AnimationController remove_speical_character_controller;
  late AnimationController convert_to_lowercase_controller;
  late AnimationController remove_punctuation_controller;
  late AnimationController segment_word_controller;
  late AnimationController pos_tag_controller;

//
  bool enabled_segment_sentence_controller = true;
  bool enabled_remove_special_character_controller = false;
  bool enabled_convert_to_lowercase_controller = false;
  bool enabled_remove_punctuation_controller = false;
  bool enabled_segment_word_controller = false;
  bool enabled_pos_tag_controller = false;

  var output = "";
  var label = "Output";

  final TextEditingController _controller = TextEditingController();
  List<List<dynamic>> _results = [];
  List<String> _stepsResults = [
    "",
    "",
    "",
    "",
    "",
    ""
  ]; // Store results for each step

  // bool _isPunctuationRemoved = false; // Track if punctuation has been removed

  final List<String> specialCharacters = [
    // Punctuation Marks
    "'", '"', '-', '_', '(', ')', '[', ']', '{', '}', '/',
    '\\', '|', '#', '%', '@', '&', '*', '+', '=', '<', '>', '^', '~', '`',
    // Currency Symbols
    '\$', '€', '£', '¥', '₹', '¢', '₽', '₩', '₪', '₫', '₭', '₦',
    // Mathematical Symbols
    '+', '-', '*', '/', '=', '<', '>', '±', '×', '÷', '≠', '≈', '≤', '≥', '%',
    '√', '∞', '∑', '∏', '∫', '∆', '∂', '∇', '∈', '∉', '∩', '∪',
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
          _stepsResults[5] = _results
              .map((result) => 'Words: ${result.join(', ')}')
              .join('\n');
          output = "";
          for (int i = 0; i < _results.length; i++) {
            output += "${i + 1} ${_results[i].join(', ')}\n\n";
          }
          label = " Predicted POS Tags ";
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
      _stepsResults[3] =
          //',', ':', ';', '!',
          _stepsResults[2]
              .replaceAll('.', '')
              .replaceAll('?', '')
              .replaceAll(',', '')
              .replaceAll(';', '')
              .replaceAll('!', '')
              .replaceAll(';', '');
      // _isPunctuationRemoved = true; // Mark punctuation as removed
    });
  }

  void _segmentWords() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/segment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': _stepsResults[3]}),
      );

      if (response.statusCode == 200) {
        // Decode and cast the response body to List<List<String>>
        List<dynamic> data = json.decode(response.body);
        List<List<String>> segments =
            data.map((item) => List<String>.from(item)).toList();

        setState(() {
          output = segments.map((segment) => segment.join(' ')).join('\n');
          _stepsResults[4] = output;
          // Convert each list to a string and join with space, then join lists with '\n'
          output = segments.map((segment) => segment.join(' / ')).join('\n\n');
        });
      } else {
        print('Failed to load predictions: ${response.statusCode}');
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print('Error during request: $e');
      // Handle error in UI or log it
    }
    // _stepsResults[4] = _stepsResults[3];
  }

  void _segmentSentences() {
    setState(() {
      String text = _controller.text;

      // Replace multiple spaces with a single space
      text = text.replaceAll(RegExp(r'\s+'), ' ');

      _stepsResults[0] = text
          .split(RegExp(r'(?<=[.?\n])'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .join('\n\n');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    segment_sentence_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    segment_sentence_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        segment_sentence_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        segment_sentence_controller.forward(from: 0.0);
      }
    });
    segment_sentence_controller.forward();
  }

  init_segment_sentence() {
    segment_sentence_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    segment_sentence_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        segment_sentence_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        segment_sentence_controller.forward(from: 0.0);
      }
    });
    segment_sentence_controller.forward();
  }

  //init Remove special character
  init_remove_special_character() {
    remove_speical_character_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    remove_speical_character_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        remove_speical_character_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        remove_speical_character_controller.forward(from: 0.0);
      }
    });
    remove_speical_character_controller.forward();
  }

  //init Convert to lowercase
  init_convert_to_lowercase() {
    convert_to_lowercase_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    convert_to_lowercase_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        convert_to_lowercase_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        convert_to_lowercase_controller.forward(from: 0.0);
      }
    });
    convert_to_lowercase_controller.forward();
  }

  //init remove punctuation
  init_remove_punctuation() {
    remove_punctuation_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    remove_punctuation_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        remove_punctuation_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        remove_punctuation_controller.forward(from: 0.0);
      }
    });
    remove_punctuation_controller.forward();
  }

  //init remove punctuation
  init_segment_word() {
    segment_word_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    segment_word_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        segment_word_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        segment_word_controller.forward(from: 0.0);
      }
    });
    segment_word_controller.forward();
  }

  //init remove punctuation
  init_pos_tag() {
    pos_tag_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    pos_tag_controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        pos_tag_controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        pos_tag_controller.forward(from: 0.0);
      }
    });
    pos_tag_controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.black,
      Colors.blue,
      Colors.yellow,
      Colors.pink,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Horizon',
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: Column(
          children: [
            // SizedBox(
            //   height: 20,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _stepsResults = ["", "", "", "", "", ""];
                      _controller.clear();
                      output = "";
                      label = 'Output';
                      enabled_segment_sentence_controller=true;
                      enabled_convert_to_lowercase_controller=false;
                      enabled_remove_special_character_controller=false;
                      enabled_pos_tag_controller=false;
                      enabled_segment_word_controller=false;
                    });
                  },
                  child: Image.asset(
                    'assets/images/hat.png',
                    width: 120,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Hybrid Approach To Rawang Language Word Segmentation using Part-of-Speech Tagging',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                  ],
                  isRepeatingAnimation: true,
                  repeatForever: true,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, bottom: 15, top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'Enter Rawang Text',
                            labelStyle: TextStyle(
                              fontSize: 17,
                              color: Colors.lightBlueAccent,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                   
                                  color: Colors.blueAccent, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: 25 ,
                      ),
                                 Stack(
                                  clipBehavior: Clip.none,
                        children: [
                          // Bottom shadow
                          Positioned(
                            bottom: -8.0,
                            right: -8.0,
                            child: Container(
                              width: 100.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                _stepsResults = ["","","","","",""];
                                _controller.clear();
                                output="";
                              });
                            },
                            child: Container(
                              width: 100.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.blue,

                              ),
                              child: Center(
                                child: Text(
                                  'CLEAR', 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Column(
                  children: [
                    //swiper view

                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.46,
                      padding: EdgeInsets.all(0),
                      child:
                          // Image.asset('assets/images/slide7.jpg')

                          Swiper(
                              autoplay: true,
                              autoplayDelay: 8000,
                              itemBuilder: (context, index) {
                                return Image.asset(
                                    'assets/images/slide${index + 1}.jpg');
                              },
                              itemCount: 6,
                              pagination: const SwiperPagination(
                                builder: DotSwiperPaginationBuilder(
                                  color: Colors.grey, // Color of dots
                                  activeColor:
                                      Colors.white, // Color of active dot
                                  size: 7.0, // Size of dots
                                  activeSize: 10.0, // Size of active dot
                                ),
                              )
                              // control: const SwiperControl(),
                              ),
                    ),
                    SizedBox(
                      height: 30,
                    ),

                    // Image.asset(
                    //   'assets/images/manaw2.png',
                    //   width: MediaQuery.of(context).size.width * 0.35,
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Supervised by',
                                  style: TextStyle(fontSize: 17.4)),
                              Text('Dr. Naw Thiri Wai Khin',
                                  style: TextStyle(fontSize: 17.4)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Presented by',
                                  style: TextStyle(fontSize: 17.4)),
                              Text('Mg Mabu Phong (6IST-21)',
                                  style: TextStyle(fontSize: 17.4)),
                              Text('B.E.Thesis',
                                  style: TextStyle(fontSize: 17.4)),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                Column(
                  children: [
                    enabled_segment_sentence_controller
                        ? Row(
                            children: [
                              AnimatedBuilder(
                                animation: segment_sentence_controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: const [
                                          Colors.purple,
                                          Colors.purpleAccent,
                                          Colors.blue,
                                        ], stops: [
                                          0.0,
                                          segment_sentence_controller.value,
                                          1.0
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          WavyAnimatedText('Segment Sentences',
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        isRepeatingAnimation: true,
                                        onTap: () {
                                          // if text filed is empty
                                          if (_controller.text.isEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Input Error'),
                                                  content: Text(
                                                      ' Input Text is Empty! Please Enter Rawang Text.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              _segmentSentences();
                                              output = '${_stepsResults[0]}';
                                              label = ' Segmented Sentences ';
                                              enabled_remove_special_character_controller =
                                                  true;
                                              enabled_segment_sentence_controller =
                                                  false;
                                            });
                                            init_remove_special_character();
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 50,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 250,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
                                    Colors.blue,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Segment Sentences',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _stepsResults[0].isEmpty
                                  ? SizedBox(
                                      width: 50,
                                    )
                                  : Image.asset(
                                      'assets/images/file.png',
                                      width: 50,
                                    )
                            ],
                          ),
                    // if (_stepsResults[0].isNotEmpty)
                    //   Text(' ${_stepsResults[0]}'),
                    SizedBox(height: 20),
                    enabled_remove_special_character_controller
                        ? Row(
                            children: [
                              AnimatedBuilder(
                                animation: remove_speical_character_controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.purple,
                                          Colors.purpleAccent,
                                          Colors.blue,
                                        ], stops: [
                                          0.0,
                                          remove_speical_character_controller
                                              .value,
                                          1.0
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          WavyAnimatedText(
                                              'Remove Special Characters',
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        isRepeatingAnimation: true,
                                        onTap: () {
                                          setState(() {
                                            _removeSpecialCharacters();
                                            output = _stepsResults[1];
                                            label =
                                                ' Removed Special Characters ';
                                            enabled_convert_to_lowercase_controller =
                                                true;
                                            enabled_remove_special_character_controller =
                                                false;
                                          });
                                          init_convert_to_lowercase();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 50,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 250,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
                                    Colors.blue,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Remove Special Characters',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _stepsResults[1].isEmpty
                                  ? SizedBox(
                                      width: 50,
                                    )
                                  : Image.asset(
                                      'assets/images/file.png',
                                      width: 50,
                                    )
                            ],
                          ),
                    // if (_stepsResults[1].isNotEmpty)
                    //   Text(' ${_stepsResults[1]}'),
                    SizedBox(height: 20),
                    enabled_convert_to_lowercase_controller
                        ? Row(
                            children: [
                              AnimatedBuilder(
                                animation: remove_speical_character_controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.purple,
                                          Colors.purpleAccent,
                                          Colors.blue,
                                        ], stops: [
                                          0.0,
                                          remove_speical_character_controller
                                              .value,
                                          1.0
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          WavyAnimatedText(
                                              'Convert to Lowercase',
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        isRepeatingAnimation: true,
                                        onTap: () {
                                          setState(() {
                                            _convertToLowerCase();
                                            output = _stepsResults[2];
                                            label = " Converted to Lowercase ";
                                            enabled_remove_punctuation_controller =
                                                true;
                                            enabled_convert_to_lowercase_controller =
                                                false;
                                          });
                                          init_remove_punctuation();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 50,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 250,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
                                    Colors.blue,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Convert to Lowercase',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _stepsResults[2].isEmpty
                                  ? SizedBox(
                                      width: 50,
                                    )
                                  : Image.asset(
                                      'assets/images/file.png',
                                      width: 50,
                                    )
                            ],
                          ),
                    // if (_stepsResults[2].isNotEmpty)
                    //   Text(' ${_stepsResults[2]}'),
                    SizedBox(height: 20),
                    enabled_remove_punctuation_controller
                        ? Row(
                            children: [
                              AnimatedBuilder(
                                animation: remove_speical_character_controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.purple,
                                          Colors.purpleAccent,
                                          Colors.blue,
                                        ], stops: [
                                          0.0,
                                          remove_punctuation_controller.value,
                                          1.0
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          WavyAnimatedText(
                                              'Remove Punctuations',
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        isRepeatingAnimation: true,
                                        onTap: () {
                                          _removePunctuations();
                                          setState(() {
                                            output = _stepsResults[3];
                                            label = " Removed Punctuations ";
                                            enabled_segment_word_controller =
                                                true;
                                            enabled_remove_punctuation_controller =
                                                false;
                                          });
                                          init_segment_word();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 50,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 250,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
                                    Colors.blue,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Remove Punctuations',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _stepsResults[3].isEmpty
                                  ? SizedBox(
                                      width: 50,
                                    )
                                  : Image.asset(
                                      'assets/images/file.png',
                                      width: 50,
                                    )
                            ],
                          ),
                    // if (_stepsResults[3].isNotEmpty)
                    //   Text(' ${_stepsResults[3]}'),
                    SizedBox(height: 20),
                    enabled_segment_word_controller
                        ? Row(
                            children: [
                              AnimatedBuilder(
                                animation: remove_speical_character_controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.purple,
                                          Colors.purpleAccent,
                                          Colors.blue,
                                        ], stops: [
                                          0.0,
                                          segment_word_controller.value,
                                          1.0
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          WavyAnimatedText('Segment Words',
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        isRepeatingAnimation: true,
                                        onTap: () async {
                                          setState(() {
                                            label = "Segmenting....";
                                          });
                                          await Future.delayed(
                                              Duration(seconds: 3));
                                          _segmentWords();
                                          setState(() {
                                            output = _stepsResults[4];
                                            label = " Segmented Words ";
                                            enabled_pos_tag_controller = true;
                                            enabled_segment_word_controller =
                                                false;
                                          });
                                          init_pos_tag();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 50,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 250,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
                                    Colors.blue,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Segment Words',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _stepsResults[4].isEmpty
                                  ? SizedBox(
                                      width: 50,
                                    )
                                  : Image.asset(
                                      'assets/images/file.png',
                                      width: 50,
                                    )
                            ],
                          ),
                    // if (_stepsResults[4].isNotEmpty)
                    //   Text(' ${_stepsResults[4]}'),
                    SizedBox(height: 20),
                    enabled_pos_tag_controller
                        ? Row(
                            children: [
                              AnimatedBuilder(
                                animation: remove_speical_character_controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 250,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.purple,
                                          Colors.purpleAccent,
                                          Colors.blue,
                                        ], stops: [
                                          0.0,
                                          pos_tag_controller.value,
                                          1.0
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          WavyAnimatedText('Predict POS Tags',
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.5,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                        isRepeatingAnimation: true,
                                        onTap: () async {
                                          // Update the output variable with the results
                                          setState(() {
                                            label = "Predicting....";
                                          });
                                          await Future.delayed(
                                              Duration(seconds: 4));
                                          _predictPOS();
                                          setState(() {
                                            // enabled_segment_sentence_controller =
                                            //     true;
                                            enabled_pos_tag_controller = false;
                                          });
                                          init_segment_sentence();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 50,
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 250,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
                                    Colors.blue,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Predict POS Tags',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold)),
                              ),
                              _stepsResults[5].isEmpty
                                  ? SizedBox(
                                      width: 50,
                                    )
                                  : Image.asset(
                                      'assets/images/file.png',
                                      width: 50,
                                    )
                            ],
                          ),
                  ],
                ),
                SizedBox(
                  width: 11,
                ),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.63,
                        width: MediaQuery.of(context).size.width * 0.4,
                        padding: EdgeInsets.fromLTRB(15, 28, 5, 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.blueAccent, // border color
                            width: 2, // border thickness
                          ),
                          borderRadius:
                              BorderRadius.circular(10), // rounded corners
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            output,
                            style: TextStyle(
                                letterSpacing: 1, wordSpacing: 1, fontSize: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -13,
                        left: 30,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5)),
                          // color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Text(
                              textAlign: TextAlign.justify,
                              label,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
