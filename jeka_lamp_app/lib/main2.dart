import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(LampApp());
}

class LampApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LampAppState();
  }
}

class _LampAppState extends State<LampApp> {
  bool _loading = false;
  double _progressDownload = 0.0;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _progressDownload = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("data"),
          centerTitle: true,
        ),
        body: Center(
          child: Stack(
            children: [
              Image(
                image: AssetImage("assets/images/asd.webp"),
                fit: BoxFit.fill,
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: _loading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: _progressDownload,
                          ),
                          Text(
                            "${(_progressDownload * 100).round()}%",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ],
                      )
                    : Text(
                        "Press button to download",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: !_loading
              ? () {
                  setState(() {
                    _loading = true;
                    _updateProgress();
                  });
                }
              : null,
          child: Icon(Icons.cloud_download),
        ),
      ),
    );
  }

  void _updateProgress() {
    const oneSec = const Duration(milliseconds: 1);
    Timer.periodic(
      oneSec,
      (timer) {
        setState(() {
          _progressDownload += 0.002;
          if (_progressDownload >= 1.0) {
            _loading = false;
            _progressDownload = 0.0;
            timer.cancel();
            return;
          }
        });
      },
    );
  }
}
