import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBackgroundAudio {
  static const MethodChannel _channel =
      const MethodChannel('flutter_background_audio');

  static Future<void> play(String url,
      {bool isLooping = true,
      String artist = "unknown",
      String title = "unknow"}) async {
    await _channel.invokeMethod(
        "play", {"url": url, "isLooping": isLooping, "artist": artist, "title": title});
  }

  static Future<void> pause() async {
    await _channel.invokeMethod("pause");
  }

  static Future<void> stop() async {
    await _channel.invokeMethod("stop");
  }

  static Future<bool> get isPlaying async {
    return await _channel.invokeMethod("isPlaying");
  }
}
