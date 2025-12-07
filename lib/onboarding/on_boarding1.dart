import 'package:flutter/material.dart';
import 'on_boarding2.dart';

class Onboarding1 extends StatelessWidget {
const Onboarding1({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
// Icon background container
Container(
padding: const EdgeInsets.all(25),
decoration: BoxDecoration(
color: Colors.grey[200],
borderRadius: BorderRadius.circular(20),
),
child: SizedBox(
width: 140,
height: 140,
child: Image.asset(
'assets/images/logo.png',
fit: BoxFit.contain,
errorBuilder: (context, error, stackTrace) {
return const Icon(Icons.build, size: 140, color: Colors.red);
},
),
),
),
const SizedBox(height: 25),
const Text(
'Welcome to FixHub Nepal',
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
textAlign: TextAlign.center,
),
const SizedBox(height: 10),
const Text(
'Smart Vehicle Servicing',
style: TextStyle(fontSize: 16, color: Colors.grey),
textAlign: TextAlign.center,
),
const SizedBox(height: 35),
SizedBox(
width: 200, // smaller width button
child: ElevatedButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => const Onboarding2()),
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
