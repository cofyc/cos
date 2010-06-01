#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface COStatsdController : NSObject {
    @private
    CFSocketNativeHandle fd;
    CFSocketRef socketRef;
    CGFloat percent;
    CGFloat cpu_user_percent; 
    CGFloat cpu_system_percent; 
    CGFloat cpu_idle_percent;
}

@property(readwrite) CGFloat percent;
@property(readwrite) CGFloat cpu_user_percent; 
@property(readwrite) CGFloat cpu_system_percent; 
@property(readwrite) CGFloat cpu_idle_percent; 

- (void)parseStats:(struct stats_struct *)stats;

- (void)stats;

@end
