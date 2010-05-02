#import "COAppDelegate.h"
#import "COMenu.h"
#import "CORecorder.h"

@implementation COAppDelegate

- (id)init
{    
    // need this if you set LSUIElement = 1
    [NSApp activateIgnoringOtherApps:YES];
    
    // create stats menu
    COMenu *menu = [[COMenu shared] init];
    [[CORecorder shared] initWithMenu:menu];
    return self;
}

@end