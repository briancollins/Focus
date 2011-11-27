#import "BCAppDelegate.h"
#import "BCMonitor.h"
#import "BCAppPlugin.h"
#import "BCChromePlugin.h"
#import "BCMonitorEventStream.h"

#define kBCStatusIconWidth 7.0f
#define kBCStatusIconHeight 14.0f

#define kBCHighAverage 16.0f

@interface BCAppDelegate ()
@property (nonatomic, strong) BCMonitor *monitor;
@property (nonatomic, strong) NSMenuItem *keyCountMenuItem;

- (void)updateStatusItem;
@end

@implementation BCAppDelegate

@synthesize window = _window, monitor = _monitor, keyCountMenuItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[BCChromePlugin alloc] init] registerPlugin];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"hello"];
    
    self.keyCountMenuItem = [[NSMenuItem alloc] init];
    self.keyCountMenuItem.title = @"No keystrokes recorded yet";
    [menu addItem:self.keyCountMenuItem];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:kBCStatusIconWidth + 10.0f];
    statusItem.menu = menu;
    statusItem.highlightMode = YES;
    [self updateStatusItem];    
    self.monitor = [[BCMonitor alloc] init];
    [self.monitor addObserver:self forKeyPath:@"keysPerSecond" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateStatusItem];
}

- (NSImage *)statusImageWithColor:(NSColor *)color {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGSize s = CGSizeMake(kBCStatusIconWidth, kBCStatusIconHeight);
    CGContextRef context = CGBitmapContextCreate(NULL, s.width, s.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];

    
    CGContextSetLineWidth(context, 2.0f);
    [color set];
    
    float f = MIN(self.monitor.keysPerSecond, kBCHighAverage) / kBCHighAverage;
    float height = kBCStatusIconHeight * f;
    CGContextAddRect(context, CGRectMake(0, 0, kBCStatusIconWidth, height));
    CGContextFillPath(context);
    
    CGContextAddRect(context, CGRectMake(0, 0, kBCStatusIconWidth, kBCStatusIconHeight));
    CGContextStrokePath(context);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:s];
    CGImageRelease(cgImage);    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

- (void)updateStatusItem {
    statusItem.image = [self statusImageWithColor:[NSColor blackColor]];
    statusItem.alternateImage = [self statusImageWithColor:[NSColor whiteColor]];
    self.keyCountMenuItem.title = [NSString stringWithFormat:@"%d keys pressed", self.monitor.eventStream.keyStrokes];
}

- (void)dealloc {
    [self.monitor removeObserver:self forKeyPath:@"keysPerSecond"];
}

@end