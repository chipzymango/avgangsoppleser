import 'package:flutter/material.dart';

void main() {
  // program starts executing here
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Color.fromARGB(255, 240, 255, 240)),
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Reise Oppleseren",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              backgroundColor: Color.fromARGB(255, 0, 63, 14),
              foregroundColor: Colors.white,
            ),
            body: Column(
              children: [
                Container(
                    height: 300,
                    child: const Text("Hvor skal du reise?",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold))),
                Expanded(
                  child: Container(), // container to take the available space
                ),
                Container(
                    height: 50,
                    child: const Text(
                        'Eks: "Jeg skal reise fra Økern til Sinsen T"',
                        style: TextStyle(fontSize: 20, color: Colors.grey))),
                Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: MaterialButton(
                        onPressed: () {
                          print("Pressed!");
                        },
                        color: Colors.red,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.mic,
                            size: 32, color: Colors.white)))
              ],
            )));
  }
}
