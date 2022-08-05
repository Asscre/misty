#import "MistyPlugin.h"
#if __has_include(<misty/misty-Swift.h>)
#import <misty/misty-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "misty-Swift.h"
#endif

@implementation MistyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMistyPlugin registerWithRegistrar:registrar];
}
@end
