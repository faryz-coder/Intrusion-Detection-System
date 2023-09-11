import 'package:flutter/material.dart';

class ControlSystemScreen extends StatelessWidget {
  const ControlSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green,
        alignment: Alignment.center,
        child: const Text('page 2'),
      ),
    );
  }
}