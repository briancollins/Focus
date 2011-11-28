#define kBCMonitorInactivityTimeout       30.0f
#define kBCMonitorUpdateInterval          1.0f
@class BCMonitorEventStream;

@interface BCMonitor : NSObject {    
    NSInteger keystrokes;
    NSDate *lastActive;
    NSTimer *timer;
    BCMonitorEventStream *eventStream;
    NSUInteger modifierFlags;
    id eventMonitor;
}

@property (nonatomic) float keysPerSecond;
@property (nonatomic) NSInteger totalKeystrokes;

- (void)saveEventStream;

@end
