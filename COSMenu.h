#import <Cocoa/Cocoa.h>


@interface COSMenu : NSObject {
	NSStatusItem *_statusItem;
	NSImage *_statusImage;
	CGFloat _height;
}

+ (COSMenu *)shared;

- (void)update;

@end