@interface BCMonitorEventStream : NSDocument {
    NSMutableArray *events;
}

- (void)recordKeyCount:(NSInteger)keyCount application:(NSRunningApplication *)application metadata:(NSDictionary *)metadata;

@end
