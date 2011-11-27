#define kBCMonitorInactivityTimeout       30.0f
#define kBCMonitorUpdateInterval          1.0f
#define kBCMonitorMovingAverageDataPoints 1
@class BCMonitorEventStream;

@interface BCMonitor : NSObject {
    CFMachPortRef tap;
    CFRunLoopSourceRef runLoopSource;
    
    NSInteger keystrokes[kBCMonitorMovingAverageDataPoints];
    NSDate *lastActive;
    NSTimer *timer;
    BOOL isActive;
}

@property (nonatomic, strong) BCMonitorEventStream *eventStream;
@property (nonatomic) float keysPerSecond;

@end

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, BCMonitor *monitor);
