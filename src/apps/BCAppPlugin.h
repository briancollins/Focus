@interface BCAppPlugin : NSObject

+ (BCAppPlugin *)pluginForApplication:(NSString *)bundleIdentifier;
- (NSDictionary *)metadata;
- (void)registerPlugin;

@property (readonly) NSString *bundleIdentifier;

@end
