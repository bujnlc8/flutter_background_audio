package site.haihui.flutter_background_audio;

import android.media.MediaPlayer;
import android.os.Binder;

import java.io.IOException;

public class AudioServiceBinder extends Binder {
    // web audio file url
    private String audioFileUrl = "";
    // audio player
    private MediaPlayer mediaPlayer = null;

    // is loop or not
    private boolean isLooping = false;

    // current play state
    private int currentState = 0;

    public int getCurrentState() {
        return currentState;
    }

    public void setCurrentState(int currentState) {
        this.currentState = currentState;
    }

    public String getAudioFileUrl() {
        return audioFileUrl;
    }

    public void setAudioFileUrl(String audioFileUrl) {
        this.audioFileUrl = audioFileUrl;
    }

    public MediaPlayer getMediaPlayer() {
        return mediaPlayer;
    }

    public void setMediaPlayer(MediaPlayer mediaPlayer) {
        this.mediaPlayer = mediaPlayer;
    }

    public boolean isLooping() {
        return isLooping;
    }

    public void setLooping(boolean looping) {
        isLooping = looping;
    }

    // start play
    public void play() {
        if (audioFileUrl.length() == 0) {
            return;
        }
        if (mediaPlayer == null) {
            mediaPlayer = new MediaPlayer();
            mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    mediaPlayer.reset();
                    setCurrentState(0);
                }
            });
            mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    mediaPlayer.start();
                }
            });
        }
        if (currentState > 0) {
            mediaPlayer.seekTo(getCurrentState());
            mediaPlayer.start();
        } else {
            try {
                reset();
                mediaPlayer.setDataSource(audioFileUrl);
                mediaPlayer.prepareAsync();
                mediaPlayer.setLooping(isLooping);
                mediaPlayer.setScreenOnWhilePlaying(true);
            } catch (IOException e) {
                e.printStackTrace();
                mediaPlayer.release();
                mediaPlayer = null;
            }
        }
    }

    // pause play
    public void pause() {
        if (mediaPlayer != null) {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.pause();
                setCurrentState(mediaPlayer.getCurrentPosition());
            } else {
                stop();
            }
        }
    }

    // stop play
    public void stop() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    // reset the play state
    public void reset() {
        if (mediaPlayer != null) {
            mediaPlayer.reset();
        }
        setCurrentState(0);
    }

    // get isPlaying
    public boolean isPlaying() {
        if (mediaPlayer != null) {
            return mediaPlayer.isPlaying();
        }
        return false;
    }
}