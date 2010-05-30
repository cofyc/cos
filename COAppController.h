#import <Cocoa/Cocoa.h>


@interface COAppController : NSObject {
}

- (void)update:(NSTimer *)timer;

- (void)drawMemoryGraph:(CGFloat)mem_percent;

- (void)closeApp:(id)sender;

- (IBAction)editPreferences:(id)sender;

@end