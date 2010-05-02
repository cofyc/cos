#import <Cocoa/Cocoa.h>
#import "COMenu.h"

@interface CORecorder : NSObject {
    NSTimer *_checkTimer;
    COMenu *_menu;
}

+ (CORecorder *)shared;

- (id)initWithMenu:(COMenu *)menu;
- (BOOL)record:(NSTimer *)timer;

@end
