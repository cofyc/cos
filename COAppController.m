#import "COAppController.h"
#import "COStatsdController.h"
#import "COPrefsWindowController.h"

@implementation COAppController

static NSStatusBar *_statusBar = nil;
static NSStatusItem *_statusItem = nil;
static NSTimer *_checkTimer = nil;

- (id)init
{   
    // show menu
    NSLog(@"show menu");
    _statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [[_statusBar statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setHighlightMode:YES];
    NSMenu    *menu;
    NSMenuItem *menuItem;
    // Menu
    menu = [[NSMenu alloc] initWithTitle:@""];
    // Preference Item
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(editPreferences:) keyEquivalent:@","];
    [menuItem setTarget: self];
    [menu addItem: menuItem];
    // Menu Item: Quit
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(closeApp:) keyEquivalent:@"q"];
    [menuItem setTarget: self];
    [menu addItem:menuItem];
    // set AutoEnablesItem
    [_statusItem setMenu: menu];
    [_statusItem setTarget: self];
    
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [_checkTimer fire];
    return self;
}

- (void)update:(NSTimer *)timer;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // get data
    [[COStatsdController sharedStatsdController] stats];
    [self drawMemoryGraph:[[COStatsdController sharedStatsdController] percent]];
    [pool release];
}

- (void)drawMemoryGraph:(CGFloat)mem_percent
{
    /**
     * @link http://cocoadevcentral.com/d/intro_to_quartz_two/
     */
    CGFloat imageHeight = 22.0;
    CGFloat imageWidth = 22.0;
    CGFloat imageChartRadius = 8.5;
    NSPoint imageChartCenter = NSMakePoint(imageHeight / 2, imageWidth / 2);
    NSRect rect = NSMakeRect(2, 2, imageHeight - 4, imageWidth - 4);
    
    NSImage *myImage = [[NSImage alloc] initWithSize:NSMakeSize(imageHeight,  imageWidth)];
    
    [myImage lockFocus];
    
    [[NSColor darkGrayColor] setStroke];
    [[NSColor colorWithCalibratedRed:0.0 green: 0.55 blue:0.90 alpha:1.0] setFill];
    NSBezierPath *path1 = [NSBezierPath bezierPathWithOvalInRect:rect];
    [path1 setLineWidth:0.3];
    [path1 stroke];
    
    NSBezierPath *path2 = [NSBezierPath bezierPath];
    [path2 moveToPoint:imageChartCenter];
    NSInteger startAngle = 90;
    NSInteger endAngle = startAngle +  (1 - mem_percent) * 360;
    [path2 appendBezierPathWithArcWithCenter:imageChartCenter radius:imageChartRadius startAngle:startAngle endAngle:endAngle clockwise: YES];
    [path2 fill];
    
    [myImage unlockFocus];
    
    // set image
    [_statusItem setImage:myImage];
    [myImage release];
}

- (void)closeApp:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)editPreferences:(id)sender
{
	[[COPrefsWindowController sharedPrefsWindowController] showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES]; // need this if you set LSUIElement = 1
}

@end
