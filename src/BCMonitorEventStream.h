@interface BCMonitorEventStream : NSDocument {
    NSMutableArray *events;
}

@property (nonatomic) NSInteger keyStrokes;
- (void)recordKeyCount:(NSInteger)keyCount application:(NSString *)bundleIdentifier metadata:(NSDictionary *)metadata;

@end
