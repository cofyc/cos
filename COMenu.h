#import <Cocoa/Cocoa.h>


@interface COMenu : NSObject {
    NSStatusBar *_statusBar;
    NSStatusItem *_statusItem;
    CGFloat _mem_percent;
}

+ (COMenu *)shared;

- (void)update;

@end