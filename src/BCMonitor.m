#import "BCMonitor.h"
#import "BCMonitorEventStream.h"
#import "BCAppPlugin.h"

@interface BCMonitor ()
- (void)eventReceived:(CGEventRef)event ofType:(CGEventType)type;

@property (nonatomic, strong) NSString *currentPath;
@property (readonly) BCMonitorEventStream *eventStream;
@end

CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, BCMonitor *monitor) {
    [monitor eventReceived:event ofType:type];
    return event;
}

@implementation BCMonitor
@synthesize keysPerSecond, totalKeystrokes, currentPath;

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
    self.keysPerSecond = movingAverage;
    
    for (NSInteger i = kBCMonitorMovingAverageDataPoints - 1; i >= 1; i--) {
        keystrokes[i] = keystrokes[i - 1];
    }
    
    if (lastActive && [[NSDate date] timeIntervalSinceDate:lastActive] < kBCMonitorInactivityTimeout) {
        isActive = YES;
    } else {
        isActive = NO;
        return;
    }
    
    NSRunningApplication *activeApplication = nil;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (app.active) {
            activeApplication = app;
            break;
        }
    }
    
    NSDictionary *metaData = nil;
    
    if (activeApplication) {  
        metaData = [[BCAppPlugin pluginForApplication:activeApplication.bundleIdentifier] metadata];
    }
    
    self.totalKeystrokes += keystrokes[0];
    [self.eventStream
     recordKeyCount:keystrokes[0] 
     application:activeApplication
     metadata:metaData];
    keystrokes[0] = 0;
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



- (NSString *)pathForHourlySave:(NSDate *)date {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = [@"~/Library/Application Support/Focus/" stringByExpandingTildeInPath];
    
    if (![fileManager fileExistsAtPath:folder]) {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    NSDate *today = date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH.00"];    
    NSString *fileName = [NSString stringWithFormat:@"%@.FocusEvents", [dateFormat stringFromDate:today]];
    return [folder stringByAppendingPathComponent:fileName];
}

- (void)saveEventStream {
    [eventStream writeToURL:[NSURL fileURLWithPath:self.currentPath] ofType:@"FocusEvents" error:NULL];
}

- (BCMonitorEventStream *)eventStream {
    NSString *newPath = [self pathForHourlySave:[NSDate date]];
    if ([self.currentPath isEqualToString:newPath]) {
        return eventStream;
    } 
    
    if (eventStream) {
        [eventStream writeToURL:[NSURL fileURLWithPath:self.currentPath] ofType:@"FocusEvents" error:NULL];
    }
    
    self.currentPath = newPath;
    
    eventStream =
    [[BCMonitorEventStream alloc] initWithContentsOfURL:[NSURL fileURLWithPath:newPath] ofType:@"FocusEvents" error:NULL];
    
    if (!eventStream) {
        eventStream = [[BCMonitorEventStream alloc] init];
    }
    
    return eventStream;
}


@end
