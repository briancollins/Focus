#import "BCMonitorEventStream.h"
#define X_OR_NULL(x) x ? x : [NSNull null]

@implementation BCMonitorEventStream
@synthesize keyStrokes;

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    return YES;
}

- (id)init {
    if ((self = [super init])) {
        events = [NSMutableArray array];
    }
    
    return self;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    NSString *error;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:events format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    return data;
}

- (void)recordKeyCount:(NSInteger)keyCount application:(NSString *)bundleIdentifier metadata:(NSDictionary *)metadata {
    self.keyStrokes += keyCount;
    [events addObject:
     [NSDictionary dictionaryWithObjectsAndKeys:
      X_OR_NULL([NSNumber numberWithInteger:keyCount]), @"keyCount",
      X_OR_NULL(bundleIdentifier),                      @"application",
      X_OR_NULL(metadata),                              @"metadata", nil]];
}

@end
