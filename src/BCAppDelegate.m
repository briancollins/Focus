#import "BCAppDelegate.h"
#import "BCMonitor.h"
#import "BCAppPlugin.h"
#import "BCChromePlugin.h"

@interface BCAppDelegate ()
@property (nonatomic, strong) BCMonitor *monitor;
@end

@implementation BCAppDelegate

@synthesize window = _window, monitor = _monitor;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[BCChromePlugin alloc] init] registerPlugin];
    
    self.monitor = [[BCMonitor alloc] init];
}

@end

