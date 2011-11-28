#import <ScriptingBridge/ScriptingBridge.h>
#import "BCChromePlugin.h"
#import "SBChrome.h"

@implementation BCChromePlugin

- (NSString *)bundleIdentifier {
    return @"com.google.Chrome";
}

- (NSDictionary *)metadata {
    SBChromeApplication *app = [SBApplication applicationWithBundleIdentifier:self.bundleIdentifier];
    SBChromeWindow *front = nil;
    NSInteger frontIndex = NSIntegerMax;
    for (SBChromeWindow *window in [app windows]) {
        if (window.index < frontIndex) {
            front = window;
            frontIndex = window.index;
        }
    }
    
    if (front && front.activeTab.URL) {
        return [NSDictionary dictionaryWithObject:front.activeTab.URL forKey:@"URL"];
    }
    
    return nil;
}

@end
