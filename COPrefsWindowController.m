#import "COPrefsWindowController.h"
#import "COLoginItem.h"

@implementation COPrefsWindowController

- (void)setupToolbar
{
    // GENERAL
    [self addView:generalPrefsView label:@"General" image:[NSImage imageNamed:@"General"]];
    // UPDATES
    [self addView:softwareUpdatePrefsView label:@"Software Update" image:[NSImage imageNamed:@"Software Update"]];
}

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (BOOL)startAtLogin
{
    return [COLoginItem willStartAtLogin:[self appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    [COLoginItem setStartAtLogin:[self appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
}

/* NSWindow itself is actually a fairly lightweight class, and most of what we think of as standard window behavior is done by the frame view.
 so we implement the -keyDown: method that receives those keystrokes and handle them */
- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSCommandKeyMask) {
        if ([[theEvent characters] isEqualToString:@"w"]) {
            [self close];
        }
    }
}

@end
