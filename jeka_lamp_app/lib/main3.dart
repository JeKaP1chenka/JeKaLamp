import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(_App());
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Counter"),
          centerTitle: true,
        ),
        body: Align(
            alignment: Alignment(0.5, 0.5),
            // padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tap '-' to dec"),
                  LampApp(),
                  Text("Tap '+' to inc")
                ],
              ),
            )),
      ),
    );
  }
}

class LampApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LampAppState();
  }
}

class _LampAppState extends State<LampApp> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  _counter--;
                });
              },
              icon: Icon(Icons.remove)),
          Text("${_counter}"),
          IconButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              icon: Icon(Icons.add))
        ],
      ),
    );
  }
}
