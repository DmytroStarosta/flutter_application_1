import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController controller = TextEditingController();
  String text = 'Тут може бути ваша реклама';
  String inputText = '';
  Color currentColor = Colors.deepPurple;

  void _changeText() {
    setState(() {
      String trimmedInput = inputText.trim();
      if (trimmedInput.isNotEmpty) {
        if (trimmedInput.toLowerCase() == 'reset') {
          text = 'Тут може бути ваша реклама';
          currentColor = Colors.deepPurple;
        } else {
          text = inputText;
          currentColor = Color(
            (Random().nextDouble() * 0xFFFFFF).toInt(),
          ).withValues(alpha: 1);
        }
        controller.clear();
        inputText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: currentColor,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Banner:'),
            Text(
              text,
              style: TextStyle(
                color: currentColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 400,
              height: 70,
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    inputText = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Введіть вашу рекламу',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _changeText,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentColor,
              ),
              child: const Icon(
                Icons.done,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
