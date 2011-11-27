#import "BCMonitorEventStream.h"
#define X_OR_NULL(x) x ? x : [NSNull null]

@implementation BCMonitorEventStream

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    events = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return !!events;
}

- (id)init {
    if ((self = [super init])) {
        events = [NSMutableArray array];
    }
    
    return self;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    return [NSKeyedArchiver archivedDataWithRootObject:events];
}

- (void)recordKeyCount:(NSInteger)keyCount application:(NSRunningApplication *)application metadata:(NSDictionary *)metadata {
    [events addObject:
     [NSDictionary dictionaryWithObjectsAndKeys:
      X_OR_NULL([NSNumber numberWithInteger:keyCount]), @"keyCount",
      X_OR_NULL(application.bundleIdentifier),          @"application",
      X_OR_NULL(application.localizedName),             @"displayName",
      X_OR_NULL(metadata),                              @"metadata", nil]];
}

@end
