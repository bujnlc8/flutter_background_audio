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
    let instance = MyAudioPlayer.shared
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "play"{
            guard let args = call.arguments as? [String:Any] else{
                result("iOS could not recognize flutter arguments in method: (play)")
                return
            }
            instance.play(
                url: args["url"] as! String, isLooping: args["isLooping"] as! Bool,
                artist: args["artist"] as! String, title: args["title"] as! String)
        }else if call.method == "pause" {
            instance._pause()
        }else if call.method == "stop"{
            instance.stop()
        }else if call.method == "isPlaying"{
            result(instance._isPlaying())
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
    
    static let shared = MyAudioPlayer()
    
    var audioPlayer:AVPlayer!
    var currentState:CMTime!
    var playerItem:AVPlayerItem!
    var isPlaying:Bool
    var _isLooping:Bool
    var lastUrl:String
    var _artist:String
    var _title:String
    var commandCenter:MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    var playInfo = Dictionary<String, Any>()
    var asset:AVAsset!
    
    private override init() {
        self.isPlaying = false
        self.currentState = nil
        self.lastUrl = ""
        self._artist = ""
        self._title = ""
        self._isLooping = false
        self.playerItem = nil
        self.asset = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.commandCenter.playCommand.removeTarget(self)
        self.commandCenter.pauseCommand.removeTarget(self)
        // self.commandCenter.nextTrackCommand.removeTarget(self)
    }
    
    @objc func playItemDidReachEnd(notification:NSNotification) {
        isPlaying = false
        currentState = nil
        if _isLooping{
            if audioPlayer != nil{
                if playerItem != nil{
                    MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = ceil(CMTimeGetSeconds(playerItem.asset.duration))
                    audioPlayer.seek(to: playerItem.asset.duration)
                }
                play(url: self.lastUrl, isLooping: _isLooping, artist: _artist, title: _title)
            }
        }else{
            stop()
        }
    }
    @objc func togglePlay(event: MPRemoteCommandEvent)->MPRemoteCommandHandlerStatus{
        if event.command == self.commandCenter.playCommand{
            play(url: lastUrl, isLooping: _isLooping, artist: _artist, title: _title)
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    @objc func togglePause(event: MPRemoteCommandEvent)->MPRemoteCommandHandlerStatus{
        if event.command == commandCenter.pauseCommand{
            _pause()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    @objc func destroyPlay(event: MPRemoteCommandEvent)->MPRemoteCommandHandlerStatus{
        if event.command == commandCenter.nextTrackCommand{
            stop()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    func play(url:String, isLooping:Bool, artist:String, title: String){
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(playItemDidReachEnd(notification: )), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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
        if audioPlayer == nil || lastUrl != url{
            asset = AVAsset(url: NSURL(string: url)! as URL)
            playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["playable"])
            audioPlayer = AVPlayer(playerItem: playerItem)
            //audioPlayer = AVPlayer(url: NSURL(string: url)! as URL)
        }
        playInfo[MPMediaItemPropertyArtist] = artist
        playInfo[MPMediaItemPropertyTitle] = title
        playInfo[MPMediaItemPropertyAssetURL] = url
        playInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds(playerItem.asset.duration)
        if currentState != nil {
            audioPlayer.seek(to: currentState)
            playInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentState)
        }else{
            audioPlayer.seek(to: CMTime.zero)
            playInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        }
        var image = UIImage(named: "artwork.jpeg" )
        if image == nil{
            image = UIImage(named: "artwork.png" )
        }
        if image != nil{
            var artwork:MPMediaItemArtwork;
            if #available(iOS 10.0, *) {
                artwork = MPMediaItemArtwork.init(boundsSize: image!.size, requestHandler: { (size) -> UIImage in
                    return image!
                })
            } else {
                artwork = MPMediaItemArtwork(image: image!)
            }
            playInfo[MPMediaItemPropertyArtwork] = artwork
        }
        playInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playInfo
        audioPlayer.play()
        isPlaying = true
        _isLooping = isLooping
        lastUrl = url
        _artist = artist
        _title = title
        currentState = nil
        commandCenter.nextTrackCommand.isEnabled = false;
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.playCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.pauseCommand.addTarget(self, action: #selector(togglePause(event: )))
        commandCenter.playCommand.addTarget(self, action: #selector(togglePlay(event: )))
        // commandCenter.nextTrackCommand.addTarget(obj, action: #selector(destroyPlay))
        //commandCenter.togglePlayPauseCommand.addTarget(obj, action: #selector(togglePlayStop))
    }
    
    func _pause(){
        if audioPlayer !== nil{
            currentState = audioPlayer.currentTime()
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(currentState)
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            audioPlayer.pause()
        }
        isPlaying=false
    }
    
    func stop(){
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
    func _isPlaying()->Bool{
        return isPlaying
    }
}
