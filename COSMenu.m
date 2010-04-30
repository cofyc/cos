#import "COSMenu.h"

static COSMenu *_sharedCOSMenu = nil;

@implementation COSMenu

+ (COSMenu *)shared
{
	if (!_sharedCOSMenu) {
		_sharedCOSMenu = [self alloc];
	}
	return _sharedCOSMenu;
}

- (id)init
{
	if (self == [super init]) {
		_statusImage = [[NSImage alloc] initWithSize:NSMakeSize(20,  20)];
		_height = 10.0;
		[self show];
		return self;
	} else {
		return nil;
	}
}

- (void)show
{
	NSLog(@"show menu");
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[_statusItem setHighlightMode:YES];
	NSMenu	*menu;
	NSMenuItem *menuItem;
	// Menu
	menu = [[NSMenu alloc] initWithTitle:@""];
	// Menu Item: Quit
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(closeApp:) keyEquivalent:@"q"];
	[menuItem setTarget: self];
	[menu addItem:menuItem];
	// set AutoEnablesItem
	[_statusItem setMenu: menu];
	[_statusItem setTarget: self];
	[self update];
}

- (void)closeApp:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}
	 
- (void)update
{
	_height--;
	NSLog(@"update menu, height: %f", _height);
	[_statusImage lockFocus];
	NSRect		imageRect;
	imageRect.size	 = [_statusImage size];
	NSBezierPath *path = [[NSBezierPath alloc] init];
	[path moveToPoint:NSMakePoint(0, _height)];
	[path lineToPoint:NSMakePoint(20, _height)];
	[[NSColor blueColor] set];
	//[@"text" drawAtPoint: NSZeroPoint withAttributes: nil];
	[path stroke];
	[_statusImage unlockFocus];
	[_statusImage	drawAtPoint: NSMakePoint(0.0, 0.0)
			  fromRect: imageRect
			 operation: NSCompositeSourceOver
			  fraction: 1.0];
	[_statusItem setImage:_statusImage];
}

@end