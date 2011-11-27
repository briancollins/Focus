#import "BCMonitorEventStream.h"

@implementation BCMonitorEventStream

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    return [NSData data];
}

@end
