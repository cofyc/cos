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
    
    _memoryStatusItem = [self newStatusItem:@"Memory"];
    _cpuStatusItem = [self newStatusItem:@"CPU"];
    
    _statsdController = [[COStatsdController alloc] init];
    
    return self;
}

- (void)update:(NSTimer *)timer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // get stats
    [_statsdController stats];
    
    // draw stats
    [self drawMemoryGraph:[_statsdController percent]];
    [self drawCPUGraph:[_statsdController cpu_user_percent]
        withSysPercent:[_statsdController cpu_system_percent]
       withIdlePercent:[_statsdController cpu_idle_percent]];
    
    [pool release];
}

- (NSStatusItem*)newStatusItem:(NSString*)title
{
    NSStatusItem *_statusItem = [[_statusBar statusItemWithLength:NSSquareStatusItemLength] retain];
    
    /* Setup Menu */
    NSMenu    *menu;
    
    // Menu
    menu = [[NSMenu alloc] initWithTitle:@""];
    
    NSMenuItem *menuItem;
    
    // Title Item
    menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:title];
    [menu addItem: menuItem];
    
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
    static CGFloat _user_percent = 0;
    static CGFloat _sys_percent = 0;
    if (_user_percent == user_percent && _sys_percent == sys_percent) {
        NSLog(@"nothing changed");
        return;
    }
    
    CGFloat imageHeight = [_statusBar thickness];
    CGFloat imageWidth = [_statusBar thickness];
    CGFloat imageChartRadius = 8.5;
    NSPoint imageChartCenter = NSMakePoint(imageHeight / 2, imageWidth / 2);
    NSRect rect = NSMakeRect(2, 2, imageHeight - 4, imageWidth - 4);
    
    NSImage *myImage = [[NSImage alloc] initWithSize:NSMakeSize(imageHeight,  imageWidth)];
    
    [myImage lockFocus];
    
    // circle
    [[NSColor darkGrayColor] setStroke];
    NSBezierPath *path1 = [NSBezierPath bezierPathWithOvalInRect:rect];
    [path1 setLineWidth:0.3];
    [path1 stroke];
    
    NSInteger startAngle;
    NSInteger endAngle;
    
    // sector 1
    [[NSColor colorWithCalibratedRed:0.14 green: 0.73 blue:0.13 alpha:1.0] setFill];
    NSBezierPath *path2 = [NSBezierPath bezierPath];
    [path2 moveToPoint:imageChartCenter];
    startAngle = 90;
    endAngle = startAngle +  (1 - user_percent) * 360;
    if (endAngle - startAngle >= 360) {
        endAngle = startAngle;
    }
    [path2 appendBezierPathWithArcWithCenter:imageChartCenter radius:imageChartRadius startAngle:startAngle endAngle:endAngle clockwise: YES];
    [path2 fill];
    
    // sector 2
    [[NSColor colorWithCalibratedRed:0.71 green: 0.21 blue:0.12 alpha:1.0] setFill];
    NSBezierPath *path3 = [NSBezierPath bezierPath];
    [path3 moveToPoint:imageChartCenter];
    startAngle = endAngle;
    endAngle = startAngle +  (1 - sys_percent) * 360;
    if (endAngle - startAngle >= 360) {
        endAngle = startAngle;
    }
    [path3 appendBezierPathWithArcWithCenter:imageChartCenter radius:imageChartRadius startAngle:startAngle endAngle:endAngle clockwise: YES];
    [path3 fill];
    
    [myImage unlockFocus];
    
    // set image
    [_cpuStatusItem setImage:myImage];
    [myImage release];
    
    _user_percent = user_percent;
    _sys_percent = sys_percent;
}

- (void)drawMemoryGraph:(CGFloat)mem_percent
{
    static CGFloat _mem_percent;
    if (_mem_percent == mem_percent) {
        return;
    }
    
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
    
    [_memoryStatusItem setImage:myImage]; 
    [myImage release];
    
    _mem_percent = mem_percent;
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
