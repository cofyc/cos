#import <Cocoa/Cocoa.h>


@interface COAppController : NSObject {
    @private
    NSStatusBar *_statusBar;
    NSTimer *_checkTimer;
    NSStatusItem *_networkStatusItem;
    NSStatusItem *_cpuStatusItem;
}

- (void)update:(NSTimer *)timer;

- (NSStatusItem*)newStatusItem;

- (void)drawCPUGraph:(CGFloat)user_percent withSysPercent:(CGFloat)sys_percent withIdlePercent:(CGFloat)idle_percent;

- (void)drawMemoryGraph:(CGFloat)mem_percent;

- (void)closeApp:(id)sender;

- (IBAction)editPreferences:(id)sender;

@end