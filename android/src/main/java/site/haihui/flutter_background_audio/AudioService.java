package site.haihui.flutter_background_audio;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class AudioService extends Service {

    private  AudioServiceBinder audioServiceBinder = new AudioServiceBinder();

    public AudioServiceBinder getAudioServiceBinder() {
        return audioServiceBinder;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return audioServiceBinder;
    }
}
