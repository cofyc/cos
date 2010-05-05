#import "COAppController.h"
#import "COMemoryStats.h"

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

- (void)closeApp:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

- (void)update:(NSTimer *)timer;
{
    /**
     * @link http://cocoadevcentral.com/d/intro_to_quartz_two/
     */
  
    // Currently, system status bar's height(thickness) and width(length) are 22 pixels.
    CGFloat imageHeight = 22.0;
    CGFloat imageWidth = 22.0;
    CGFloat imageChartRadius = 8.5;
    NSPoint imageChartCenter = NSMakePoint(imageHeight / 2, imageWidth / 2);
    NSRect rect = NSMakeRect(2, 2, imageHeight - 4, imageWidth - 4);
    CGFloat mem_percent = [COMemoryStats getPercentWithInactiveAsFree:YES];

    
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
    
    // title
   // #define STRING_ATTR [NSDictionary dictionaryWithObjectsAndKeys: [NSColor whiteColor], NSForegroundColorAttributeName, nil]
//    NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:@"MEM" attributes:STRING_ATTR];
//    NSSize stringSize = [stringToDraw size];
//    stringSize.height -= 1;
//    NSPoint destPoint = NSMakePoint((22 - stringSize.width) / 2, ((22 - stringSize.height) / 2));
//    [stringToDraw drawAtPoint: destPoint];
    
    [myImage unlockFocus];
    
    // set image
    [_statusItem setImage:myImage];
    [myImage release];
}

@end