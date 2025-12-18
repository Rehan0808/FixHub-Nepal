import 'package:flutter/material.dart';
import '../../theme/theme_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Add your hero banner and service cards here
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Home Screen Content Here'),
          ),
        ],
      ),
    );
  }
}
