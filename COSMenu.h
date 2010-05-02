#import <Cocoa/Cocoa.h>


@interface COSMenu : NSObject {
    NSStatusBar *_statusBar;
    NSStatusItem *_statusItem;
    CGFloat _mem_percent;
}

+ (COSMenu *)shared;

- (void)update;

@end