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
              title: const Text("Title!"),
              backgroundColor: Color.fromARGB(255, 30, 117, 24),
              foregroundColor: Color.fromARGB(255, 230, 255, 230),
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        margin: const EdgeInsets.all(5),
                        color: const Color.fromARGB(255, 255, 0, 0),
                        child: const Text("1")),
                    Container(
                        margin: const EdgeInsets.all(5),
                        color: const Color.fromARGB(255, 0, 255, 0),
                        child: const Text("2")),
                    Container(
                        margin: const EdgeInsets.all(5),
                        color: const Color.fromARGB(255, 0, 0, 255),
                        child: const Text("3"))
                  ],
                ),
                Expanded(
                  child: Container(), // container to take the available space
                ),
                Container(
                  child: MaterialButton(
                    onPressed: () {
                      print("Pressed!");
                    },
                    color: Colors.red,
                    shape: CircleBorder()
                  ),
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 20)

                )
              ],
            )

            /*body: Center(
          child: Container(
            child: const Text("Hi!"),            
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(10),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 200, 200, 255),
              border: Border.all(
                color: Color.fromARGB(255, 0, 0, 0),
                width: 5)
            ),
            
          ),
        )*/
            ));
  }
}
