import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        body: LampApp(),
      ),
    );
  }
}

enum ColorEvent { event_red, event_green }

class FeaturesColorBloc extends Bloc<ColorEvent, Color>{
  FeaturesColorBloc() : super(Colors.red){
    on<ColorEvent>(_onColorSwitch);
  }
  
  _onColorSwitch(ColorEvent event, Emitter<Color> emit){
    if (event == ColorEvent.event_green){
      emit(Colors.green);
    } else if (event == ColorEvent.event_red) {
      emit(Colors.red);
    } else {
      throw Exception("Wrong Event Type");
    }
  }

}

class ColorBloc {
  Color _color = Colors.red;

  final _inputEventController = StreamController<ColorEvent>();
  StreamSink<ColorEvent> get inputEventSink => _inputEventController.sink;

  final _outputStateController = StreamController<Color>();
  Stream<Color> get outputStateStream => _outputStateController.stream;

  void _mapEventToState(ColorEvent event) {
    if (event == ColorEvent.event_red) {
      _color = Colors.red;
    } else if (event == ColorEvent.event_green) {
      _color = Colors.green;
    } else {
      throw Exception("Wrong Event Type");
    }
    _outputStateController.sink.add(_color);
  }

  ColorBloc() {
    _inputEventController.stream.listen(_mapEventToState);
  }
  void dispose() {
    _inputEventController.close();
    _outputStateController.close();
  }
}

class LampApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LampAppState();
  }
}

class _LampAppState extends State<LampApp> {
  ColorBloc _bloc = ColorBloc();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: StreamBuilder(
              stream: _bloc.outputStateStream,
              initialData: Colors.red,
              builder: (context, snapshot) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: snapshot.data,
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // spacing: 10,
                // crossAxisAlignment: CrossAxisAlignment.baseline,
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () {
                      _bloc.inputEventSink.add(ColorEvent.event_red);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text(
                      "red",
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FilledButton(
                    onPressed: () {
                        _bloc.inputEventSink.add(ColorEvent.event_green);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.green),
                    ),
                    child: Text(
                      "green",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
