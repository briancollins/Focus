#define kBCMonitorInactivityTimeout       30.0f
#define kBCMonitorUpdateInterval          1.0f
#define kBCMonitorMovingAverageDataPoints 1
@class BCMonitorEventStream;

@interface BCMonitor : NSObject {    
    NSInteger keystrokes[kBCMonitorMovingAverageDataPoints];
    NSDate *lastActive;
    NSTimer *timer;
    BOOL isActive;
    BCMonitorEventStream *eventStream;
    NSUInteger modifierFlags;
    id eventMonitor;
}

@property (nonatomic) float keysPerSecond;
@property (nonatomic) NSInteger totalKeystrokes;

- (void)saveEventStream;

@end
