import Flutter
import UIKit
import MediaPlayer

public class SwiftFlutterBackgroundAudioPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_background_audio", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterBackgroundAudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "play"{
        guard let args = call.arguments as? [String:Any] else{
            result("iOS could not recognize flutter arguments in method: (play)")
            return
        }
        MyAudioPlayer.play(url: args["url"] as! String, isLooping: args["isLooping"] as! Bool)
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
}

class MyAudioPlayer{
    
    init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(MyAudioPlayer.obj)
    }
    
    static var obj = MyAudioPlayer()
    static var audioPlayer:AVPlayer!
    static var currentState:CMTime!
    static var isPlaying:Bool = false
    static var _isLooping:Bool = false
    static var lastUrl:String = ""
    
    @objc func playItemDidReachEnd(notification:NSNotification) {
        MyAudioPlayer.isPlaying = false
        if MyAudioPlayer._isLooping{
            if MyAudioPlayer.audioPlayer != nil{
                MyAudioPlayer.audioPlayer.seek(to:kCMTimeZero)
                MyAudioPlayer.audioPlayer.play()
                MyAudioPlayer.isPlaying = true
            }
        }else{
            MyAudioPlayer.currentState = kCMTimeZero
        }
    }
    
    static func play(url:String, isLooping:Bool){
        NotificationCenter.default.addObserver(obj, selector: #selector(playItemDidReachEnd(notification: )), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if audioPlayer === nil || lastUrl != url{
         audioPlayer = AVPlayer(url: NSURL(string: url)! as URL)
        }else if currentState != nil{
            audioPlayer.seek(to: currentState)
        }
        audioPlayer.play()
        isPlaying = true
        _isLooping = isLooping
        lastUrl = url
    }
    
    static func _pause(){
        if audioPlayer !== nil{
            currentState = audioPlayer.currentTime()
            audioPlayer.pause()
            isPlaying=false
        }
    }
    
    static func stop(){
        if audioPlayer !== nil{
            audioPlayer.pause()
            audioPlayer = nil
            currentState = nil
            isPlaying=false
            _isLooping = false
            lastUrl = ""
        }
      }
    static func _isPlaying()->Bool{
        return isPlaying
    }
  }
