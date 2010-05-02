#import <Cocoa/Cocoa.h>
#import "COSMenu.h"

@interface COSRecorder : NSObject {
    NSTimer *_checkTimer;
    COSMenu *_menu;
}

+ (COSRecorder *)shared;

- (id)initWithMenu:(COSMenu *)menu;
- (BOOL)record:(NSTimer *)timer;

@end
