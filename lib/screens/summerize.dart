import 'package:flutter/material.dart';

class SummerizeScreen extends StatefulWidget {
  const SummerizeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SummerizeScreenState();
  }
}

class _SummerizeScreenState extends State<SummerizeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summerize'),
        centerTitle: true,
      ),
    );
  }
}
