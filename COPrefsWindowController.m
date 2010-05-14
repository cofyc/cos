#import "COPrefsWindowController.h"

@implementation COPrefsWindowController

- (void)setupToolbar
{
    // GENERAL
    [self addView:generalPrefsView label:@"General" image:[NSImage imageNamed:@"General"]];
    // UPDATES
    [self addView:softwareUpdatePrefsView label:@"Software Update" image:[NSImage imageNamed:@"Software Update"]];
}

@end
