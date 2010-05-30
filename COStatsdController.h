#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface COStatsdController : NSObject {
    @private
    CFSocketNativeHandle fd;
    CFSocketRef socketRef;
}

@property(readwrite) CGFloat percent;

+ (COStatsdController*)sharedStatsdController;

- (void)parseStats:(struct stats_struct *)stats;

- (void)stats;

@end
