#import "COAppController.h"
#import "COStatsdController.h"
#import "COPrefsWindowController.h"

@implementation COAppController

- (id)init
{   
    _statusBar = [NSStatusBar systemStatusBar];
    
    /* Setup Updater */
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [_checkTimer fire];
    
    _networkStatusItem = [self newStatusItem];
    _cpuStatusItem = [self newStatusItem];
    
    return self;
}

- (void)update:(NSTimer *)timer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // get stats
    [[COStatsdController sharedStatsdController] stats];
    
    // draw stats
    [self drawMemoryGraph:[[COStatsdController sharedStatsdController] percent]];
    [self drawCPUGraph:[[COStatsdController sharedStatsdController] cpu_user_percent]
        withSysPercent:[[COStatsdController sharedStatsdController] cpu_sys_percent]
       withIdlePercent:[[COStatsdController sharedStatsdController] cpu_idle_percent]];
    
    [pool release];
}

- (NSStatusItem*)newStatusItem
{
    NSStatusItem *_statusItem = [[_statusBar statusItemWithLength:NSSquareStatusItemLength] retain];
    
    /* Setup Menu */
    NSMenu    *menu;
    
    // Menu
    menu = [[NSMenu alloc] initWithTitle:@""];
    
    NSMenuItem *menuItem;
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
    
    return _statusItem;
}

- (void)drawCPUGraph:(CGFloat)user_percent withSysPercent:(CGFloat)sys_percent withIdlePercent:(CGFloat)idle_percent
{
    CGFloat imageHeight = [_statusBar thickness];
    CGFloat imageWidth = [_statusBar thickness];
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
    NSInteger endAngle = startAngle +  (1 - user_percent) * 360;
    [path2 appendBezierPathWithArcWithCenter:imageChartCenter radius:imageChartRadius startAngle:startAngle endAngle:endAngle clockwise: YES];
    [path2 fill];
    
    [myImage unlockFocus];
    
    // set image
    [_cpuStatusItem setImage:myImage];
    [myImage release];
}

- (void)drawMemoryGraph:(CGFloat)mem_percent
{
    CGFloat imageHeight = [_statusBar thickness];
    CGFloat imageWidth = [_statusBar thickness];
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
    
    [_networkStatusItem setImage:myImage]; 
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
