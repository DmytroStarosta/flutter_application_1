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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
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
  String newText = 'Тут може бути ваша реклама';

  void _changeText() {
    setState(() {
      text = newText;
      controller.clear();
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
           const Text('Banner:'),
           Text(text),
           SizedBox( 
            width: 400, 
            height: 70,
            child: TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {
                  newText = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введіть вашу рекламу'
                ),
            ),
           ),
           ElevatedButton(
            onPressed: _changeText,
            child: Icon(Icons.done)
           )
          ],
        ),
      ),
    );
  }
}
