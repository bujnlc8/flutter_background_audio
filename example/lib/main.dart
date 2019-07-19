import 'package:flutter/material.dart';
import 'package:flutter_background_audio/flutter_background_audio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying=false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: 
          Column(
            children: <Widget>[
          FlatButton(
            onPressed: (){
              FlutterBackgroundAudio.play(
                "https://songci.nos-eastchina1.126.net/audio/1.m4a");
            },
           child: Text("play"),),
              FlatButton(onPressed: (){
                FlutterBackgroundAudio.pause();
              },child: Text("pause"),),
              FlatButton(onPressed: (){
                FlutterBackgroundAudio.stop();
              },child: Text("stop"),),
              FlatButton(onPressed: () async{
                bool isPlaying = await FlutterBackgroundAudio.isPlaying;
                setState(() {
                  _isPlaying = isPlaying;
                });
              },child: Text("check"),),
              Text('audio is playing? : $_isPlaying\n'),
          ],
        )),
      ),
    );
  }
}