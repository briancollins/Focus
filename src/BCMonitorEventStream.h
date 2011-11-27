@interface BCMonitorEventStream : NSDocument {
    NSMutableArray *events;
}

- (void)recordKeyCount:(NSInteger)keyCount application:(NSString *)bundleIdentifier metadata:(NSDictionary *)metadata;

@end
