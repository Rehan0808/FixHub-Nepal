import 'package:flutter/material.dart';
import 'on_boarding3.dart';

class Onboarding2 extends StatelessWidget {
const Onboarding2({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.all(25),
decoration: BoxDecoration(
color: Colors.grey[200],
borderRadius: BorderRadius.circular(20),
),
child: const Icon(Icons.directions_car, size: 120, color: Colors.red),
),
const SizedBox(height: 25),
const Text(
'Book Mechanics Easily',
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
textAlign: TextAlign.center,
),
const SizedBox(height: 10),
const Text(
'Request service anytime, anywhere',
style: TextStyle(fontSize: 16, color: Colors.grey),
textAlign: TextAlign.center,
),
const SizedBox(height: 35),
SizedBox(
width: 200,
child: ElevatedButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => const Onboarding3()),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
padding: const EdgeInsets.symmetric(vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30),
),
),
child: const Text('Next', style: TextStyle(fontSize: 16, color: Colors.white)),
),
),
],
),
),
),
);
}
}
