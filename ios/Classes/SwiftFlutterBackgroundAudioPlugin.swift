import Flutter
import UIKit
import MediaPlayer

public class SwiftFlutterBackgroundAudioPlugin: NSObject, FlutterPlugin{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_background_audio", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterBackgroundAudioPlugin()
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "play"{
            guard let args = call.arguments as? [String:Any] else{
                result("iOS could not recognize flutter arguments in method: (play)")
                return
            }
            MyAudioPlayer.play(
                url: args["url"] as! String, isLooping: args["isLooping"] as! Bool,
                artist: args["artist"] as! String, title: args["title"] as! String)
        }else if call.method == "pause" {
            MyAudioPlayer._pause()
        }else if call.method == "stop"{
            MyAudioPlayer.stop()
        }else if call.method == "isPlaying"{
            result(MyAudioPlayer._isPlaying())
        }else{
            result("Flutter method not implemented on ios")
        }
    }
    public func applicationWillTerminate(_ application: UIApplication) {
        application.resignFirstResponder()
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    public func applicationWillResignActive(_ application: UIApplication) {
        application.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}

class MyAudioPlayer: NSObject{
    
    deinit {
        NotificationCenter.default.removeObserver(MyAudioPlayer.obj)
        MyAudioPlayer.commandCenter.playCommand.removeTarget(MyAudioPlayer.obj)
        MyAudioPlayer.commandCenter.pauseCommand.removeTarget(MyAudioPlayer.obj)
        // MyAudioPlayer.commandCenter.nextTrackCommand.removeTarget(MyAudioPlayer.obj)
    }
    
    static var obj = MyAudioPlayer()
    static var audioPlayer:AVPlayer!
    static var currentState:CMTime!
    static var isPlaying:Bool = false
    static var _isLooping:Bool = false
    static var lastUrl:String = ""
    static var _artist:String = ""
    static var _title:String = ""
    static var commandCenter:MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    static var playerItem:AVPlayerItem!
    
    @objc func playItemDidReachEnd(notification:NSNotification) {
        MyAudioPlayer.isPlaying = false
        MyAudioPlayer.currentState = CMTime.zero
        if MyAudioPlayer._isLooping{
            if MyAudioPlayer.audioPlayer != nil{
                MyAudioPlayer.play(url: MyAudioPlayer.lastUrl, isLooping: MyAudioPlayer._isLooping,
                                   artist: MyAudioPlayer._artist, title: MyAudioPlayer._title)
            }
        }
    }
    @objc func togglePlay(event: MPRemoteCommandEvent)->MPRemoteCommandHandlerStatus{
        if event.command == MyAudioPlayer.commandCenter.playCommand{
            MyAudioPlayer.play(url: MyAudioPlayer.lastUrl, isLooping: MyAudioPlayer._isLooping,
                               artist: MyAudioPlayer._artist, title: MyAudioPlayer._title)
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    @objc func togglePause(event: MPRemoteCommandEvent)->MPRemoteCommandHandlerStatus{
        if event.command == MyAudioPlayer.commandCenter.pauseCommand{
            MyAudioPlayer._pause()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    @objc func destroyPlay(event: MPRemoteCommandEvent)->MPRemoteCommandHandlerStatus{
        if event.command == MyAudioPlayer.commandCenter.nextTrackCommand{
            MyAudioPlayer.stop()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    static func play(url:String, isLooping:Bool, artist:String, title: String){
        NotificationCenter.default.removeObserver(obj)
        NotificationCenter.default.addObserver(obj, selector: #selector(playItemDidReachEnd(notification: )), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if audioPlayer === nil || lastUrl != url{
            let asset = AVAsset(url: NSURL(string: url)! as URL)
            playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["playable"])
            audioPlayer = AVPlayer(playerItem: playerItem)
            //audioPlayer = AVPlayer(url: NSURL(string: url)! as URL)
        }
        var playInfo = Dictionary<String, Any>()
        playInfo[MPMediaItemPropertyArtist] = artist
        playInfo[MPMediaItemPropertyTitle] = title
        playInfo[MPMediaItemPropertyAssetURL] = url
        if playerItem !== nil{
            playInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(playerItem.asset.duration);
            if currentState != nil && !isPlaying{
                // update
                audioPlayer.seek(to: currentState)
            }
        }
        audioPlayer.play()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playInfo
        isPlaying = true
        _isLooping = isLooping
        lastUrl = url
        _artist = artist
        _title = title
        currentState = nil
        commandCenter.nextTrackCommand.isEnabled = false;
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.playCommand.removeTarget(obj)
        commandCenter.pauseCommand.removeTarget(obj)
        commandCenter.pauseCommand.addTarget(obj, action: #selector(togglePause))
        commandCenter.playCommand.addTarget(obj, action: #selector(togglePlay))
        // commandCenter.nextTrackCommand.addTarget(obj, action: #selector(destroyPlay))
        //commandCenter.togglePlayPauseCommand.addTarget(obj, action: #selector(togglePlayStop))
    }
    
    static func _pause(){
        if audioPlayer !== nil{
            currentState = audioPlayer.currentTime()
            audioPlayer.pause()
        }
        isPlaying=false
    }
    
    static func stop(){
        if audioPlayer !== nil{
            audioPlayer.pause()
            audioPlayer = nil
            currentState = nil
            playerItem = nil
            try?AVAudioSession.sharedInstance().setActive(false)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        }
        isPlaying=false
    }
    static func _isPlaying()->Bool{
        return isPlaying
    }
}
