#import "BCAppPlugin.h"

@implementation BCAppPlugin

+ (NSMutableDictionary *)applicationDictionary {
    static NSMutableDictionary *applications = nil;
    
    if (!applications) {
        applications = [NSMutableDictionary dictionary];
    }
    
    return applications;
}

+ (BCAppPlugin *)pluginForApplication:(NSString *)bundleIdentifier {
    return [[self applicationDictionary] objectForKey:bundleIdentifier];
}

- (void)registerPlugin {
    [[BCAppPlugin applicationDictionary] setObject:self forKey:self.bundleIdentifier];
}

- (NSDictionary *)metadata {
    
    return nil;
}

- (NSString *)bundleIdentifier {
    
    return nil;
}

@end
