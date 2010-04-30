#import "COSAppDelegate.h"
#import "COSMenu.h"
#import "COSRecorder.h"

@implementation COSAppDelegate

- (id)init
{	
	// need this if you set LSUIElement = 1
	[NSApp activateIgnoringOtherApps:YES];
	
	// create stats menu
	COSMenu *menu = [[COSMenu shared] init];
	[[COSRecorder shared] initWithMenu:menu];
	return self;
}

@end