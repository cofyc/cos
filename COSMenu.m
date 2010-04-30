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
		_mem_percent = 0.0;
		
		// show menu
		NSLog(@"show menu");
		_statusBar = [NSStatusBar systemStatusBar];
		_statusItem = [[_statusBar statusItemWithLength:NSVariableStatusItemLength] retain];
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
		return self;
	} else {
		return nil;
	}
}

- (void)closeApp:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}
	 
- (void)update
{
	/**
	 * @link http://cocoadevcentral.com/d/intro_to_quartz_two/
	 */
	#define STRING_ATTR [NSDictionary dictionaryWithObjectsAndKeys: [NSColor whiteColor], NSForegroundColorAttributeName, nil]
	// Currently, system status bar's height(thickness) and width(length) are 22 pixels.
	CGFloat imageHeight = 22.0;
	CGFloat imageWidth = 22.0;
	CGFloat imageChartRadius = 8.5;
	NSPoint imageChartCenter = NSMakePoint(imageHeight / 2, imageWidth / 2);
	
	NSImage *myImage = [[NSImage alloc] initWithSize:NSMakeSize(imageHeight,  imageWidth)];
	
	_mem_percent += 0.1;
	NSLog(@"update menu, mem_percent: %f", _mem_percent);
	
	[myImage lockFocus];
	
	[[NSColor blueColor] set];
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path setLineWidth: 1];
	[path moveToPoint: imageChartCenter];
	[path appendBezierPathWithArcWithCenter:imageChartCenter radius:imageChartRadius startAngle:90 endAngle:360*_mem_percent clockwise: YES];
	[[NSColor greenColor] set];
	[path fill];
	
	[[NSColor darkGrayColor] set]; 
	//[path stroke];
	
	// draw string example
//	NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:@"%" attributes:STRING_ATTR];
//	NSSize stringSize = [stringToDraw size];
//	stringSize.height -= 1;
//	NSPoint destPoint = NSMakePoint((22 - stringSize.width) / 2, ((22 - stringSize.height) / 2));
//	[stringToDraw drawAtPoint:destPoint];
	
	[myImage unlockFocus];
	
	// set image
	[_statusItem setImage:myImage];
}

@end