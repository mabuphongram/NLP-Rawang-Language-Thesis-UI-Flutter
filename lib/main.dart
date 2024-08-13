import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

import 'package:mypos/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        body: Home(),
      ),
    );
  }
}

// class POSForm extends StatefulWidget {
//   @override
//   _POSFormState createState() => _POSFormState();
// }

// class _POSFormState extends State<POSForm> {
//   final TextEditingController _controller = TextEditingController();
//   List<List<dynamic>> _results = [];

//   Future<void> _predictPOS() async {
//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/predict'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'text': _controller.text}),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         _results = List<List<dynamic>>.from(json.decode(response.body));
//       });
//     } else {
//       throw Exception('Failed to load predictions');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(50.0),
//       child: Column(
//         children: [
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(labelText: 'Enter text'),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _predictPOS,
//             child: Text('Predict POS Tags'),
//           ),
//           SizedBox(height: 20),
//           Center(
//             child: Expanded(
//               child: ListView.builder(
//                 itemCount: _results.length,
//                 itemBuilder: (context, index) {
//                   final result = _results[index];
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Words: ${result.join(', ')}',style: TextStyle(letterSpacing: 1),).animate().fade(duration: 2000.ms,delay: 600.ms).slideY(curve: Curves.easeIn),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
