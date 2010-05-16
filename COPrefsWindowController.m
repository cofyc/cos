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

@end
