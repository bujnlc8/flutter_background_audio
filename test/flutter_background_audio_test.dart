import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_background_audio/flutter_background_audio.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_background_audio');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('isPlaying', () async {
    expect(await FlutterBackgroundAudio.isPlaying, true);
  });
}