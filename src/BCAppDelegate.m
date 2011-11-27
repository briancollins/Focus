#import "BCAppDelegate.h"
#import "BCMonitor.h"

@interface BCAppDelegate ()
@property (nonatomic, strong) BCMonitor *monitor;
@end

@implementation BCAppDelegate

@synthesize window = _window, monitor = _monitor;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.monitor = [[BCMonitor alloc] init];
}

@end

