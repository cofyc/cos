#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface COPrefsWindowController : DBPrefsWindowController {
	/* Outlets for Preference Views */
	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *softwareUpdatePrefsView;
}

@property(readwrite) BOOL startAtLogin;

- (NSURL *)appURL;

@end
