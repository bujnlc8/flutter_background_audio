package site.haihui.flutter_background_audio;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterBackgroundAudioPlugin
 */
public class FlutterBackgroundAudioPlugin implements MethodCallHandler {
    private AudioService audioService = new AudioService();
    private AudioServiceBinder binder = audioService.getAudioServiceBinder();

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_background_audio");
        channel.setMethodCallHandler(new FlutterBackgroundAudioPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("play")) {
            binder.setAudioFileUrl(call.argument("url").toString());
            binder.setLooping((boolean) call.argument("isLooping"));
            binder.play();
        } else if (call.method.equals("pause")) {
            binder.pause();
        } else if (call.method.equals("stop")) {
            binder.stop();
        } else if (call.method.equals("isPlaying")) {
            result.success(binder.isPlaying());
        } else {
            result.notImplemented();
        }
    }
}