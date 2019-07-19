import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBackgroundAudio {
  static const MethodChannel _channel =
      const MethodChannel('flutter_background_audio');

  static Future<void> play(String url, {bool isLooping=true}) async{
    await _channel.invokeMethod("play", {"url": url, "isLooping": isLooping});
  }

  static Future<void> pause() async{
    await _channel.invokeMethod("pause");
  }

  static Future<void> stop() async{
    await _channel.invokeMethod("stop");
  }
  static Future<bool> get isPlaying async{
    return await _channel.invokeMethod("isPlaying");
  }
}