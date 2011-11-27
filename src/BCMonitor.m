#import "BCMonitor.h"
#import "BCMonitorEventStream.h"

@interface BCMonitor ()
- (void)eventReceived:(CGEventRef)event ofType:(CGEventType)type;
@end

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, BCMonitor *monitor) {
    [monitor eventReceived:event ofType:type];
    return event;
}

@implementation BCMonitor
@synthesize eventStream;

- (id)init {
    if ((self = [super init])) {
        for (NSInteger i = 0; i < kBCMonitorMovingAverageDataPoints; i++) {
            keystrokes[i] = 0;
        }
        
        CGEventMask mask = CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventMouseMoved) | CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventRightMouseDown);
        
        tap = CGEventTapCreate(kCGHIDEventTap, kCGTailAppendEventTap, kCGEventTapOptionListenOnly,
                               mask, (CGEventTapCallBack)eventCallback, (__bridge void *)self);
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(tap, YES);
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kBCMonitorUpdateInterval target:self selector:@selector(updateStats) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)updateStats {
    float movingAverage = 0.0f;
    
    for (NSInteger i = 0; i < kBCMonitorMovingAverageDataPoints; i++) {
        movingAverage += keystrokes[i];
    }
    
    movingAverage /= kBCMonitorMovingAverageDataPoints;
    
    for (NSInteger i = kBCMonitorMovingAverageDataPoints - 1; i >= 1; i--) {
        keystrokes[i] = keystrokes[i - 1];
    }
    
    if (lastActive && [[NSDate date] timeIntervalSinceDate:lastActive] < kBCMonitorInactivityTimeout) {
        isActive = YES;
    } else {
        isActive = NO;
    }

    keystrokes[0] = 0;
    
    if (!self.eventStream) {
        self.eventStream = [[BCMonitorEventStream alloc] init];
    }
    
    NSRunningApplication *activeApplication = nil;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (app.active) {
            activeApplication = app;
            break;
        }
    }
    
    
}

- (void)eventReceived:(CGEventRef)event ofType:(CGEventType)type {
    lastActive = [NSDate date];
    
    if (type == kCGEventKeyDown) {
        keystrokes[0] ++;
    }
}

- (void)dealloc {
    [timer invalidate], timer = nil;
    CGEventTapEnable(tap, NO);
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource), runLoopSource = NULL;
    CFRelease(tap), tap = NULL;
}

@end
