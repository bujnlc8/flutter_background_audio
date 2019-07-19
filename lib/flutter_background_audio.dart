import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBackgroundAudio {
  static const MethodChannel _channel =
      const MethodChannel('flutter_background_audio');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void play(String url) async{
    await _channel.invokeMethod("play", {"url": url, "isLooping": true});
  }

  static void pause() async{
    await _channel.invokeMethod("pause");
  }

  static void stop() async{
    await _channel.invokeMethod("stop");
  }
  static Future<bool> get isPlaying async{
    return await _channel.invokeMethod("isPlaying");
  }
}