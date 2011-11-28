#import "BCMonitor.h"
#import "BCMonitorEventStream.h"
#import "BCAppPlugin.h"

@interface BCMonitor ()
@property (nonatomic, strong) NSString *currentPath;
@property (readonly) BCMonitorEventStream *eventStream;
@end

@implementation BCMonitor
@synthesize keysPerSecond, totalKeystrokes, currentPath;

- (id)init {
    if ((self = [super init])) {
        for (NSInteger i = 0; i < kBCMonitorMovingAverageDataPoints; i++) {
            keystrokes[i] = 0;
        }
        
        NSEventMask mask = NSFlagsChangedMask | NSKeyDownMask | NSMouseMovedMask | NSLeftMouseDownMask;
        
        [NSEvent addGlobalMonitorForEventsMatchingMask:mask  handler:^(NSEvent *event){
            lastActive = [NSDate date];

            if (event.type == NSKeyDown) {
                keystrokes[0] ++;
            } else if (event.type == NSFlagsChanged) {
                if (event.modifierFlags > modifierFlags) {
                    keystrokes[0] ++;
                }
                
                modifierFlags = event.modifierFlags;
            }
        }];
        
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



- (void)dealloc {
    [timer invalidate], timer = nil;
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
