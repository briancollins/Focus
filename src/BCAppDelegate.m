#import "BCAppDelegate.h"
#import "BCMonitor.h"
#import "BCAppPlugin.h"
#import "BCChromePlugin.h"
#import "BCMonitorEventStream.h"

#define kBCStatusIconWidth 7.0f
#define kBCStatusIconHeight 13.0f

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
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:
     [[NSMenuItem alloc] initWithTitle:@"Quit Focus" action:@selector(quit) keyEquivalent:@""]];
    
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:kBCStatusIconWidth + 10.0f];
    statusItem.menu = menu;
    statusItem.highlightMode = YES;
    [self updateStatusItem];    
    self.monitor = [[BCMonitor alloc] init];
    [self.monitor addObserver:self forKeyPath:@"keysPerSecond" options:NSKeyValueObservingOptionNew context:NULL];

}
 
- (void)quit {
    [[NSApplication sharedApplication] terminate:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateStatusItem];
}

- (NSImage *)statusImageWithColor:(NSColor *)color fillColor:(NSColor *)fillColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGSize s = CGSizeMake(kBCStatusIconWidth + 4, kBCStatusIconHeight + 4);
    CGContextRef context = CGBitmapContextCreate(NULL, s.width, s.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];

    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0, CGColorCreateGenericRGB(1.0f, 1.0f, 1.0f, 0.5f));
    CGContextSetLineWidth(context, 2.0f);
    [color setStroke];
    [fillColor setFill];
    
    float f = MIN(self.monitor.keysPerSecond, kBCHighAverage) / kBCHighAverage;
    float height = kBCStatusIconHeight * f;
    CGContextAddRect(context, CGRectMake(2, 2, kBCStatusIconWidth, height));
    CGContextFillPath(context);
    
    CGContextAddRect(context, CGRectMake(2, 2, kBCStatusIconWidth, kBCStatusIconHeight));
    CGContextStrokePath(context);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:s];
    CGImageRelease(cgImage);    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return image;
}

- (void)updateStatusItem {
    statusItem.image = [self statusImageWithColor:[NSColor blackColor] fillColor:[NSColor grayColor]];
    statusItem.alternateImage = [self statusImageWithColor:[NSColor whiteColor] fillColor:[NSColor whiteColor]];
    self.keyCountMenuItem.title = [NSString stringWithFormat:@"%d Keys Pressed", self.monitor.totalKeystrokes];
}

- (void)dealloc {
    [self.monitor removeObserver:self forKeyPath:@"keysPerSecond"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.monitor saveEventStream];
}

@end