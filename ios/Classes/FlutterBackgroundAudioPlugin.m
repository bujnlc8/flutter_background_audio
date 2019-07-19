#import "FlutterBackgroundAudioPlugin.h"
#import <flutter_background_audio/flutter_background_audio-Swift.h>

@implementation FlutterBackgroundAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBackgroundAudioPlugin registerWithRegistrar:registrar];
}
@end
