#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface COStatsdController : NSObject {
}

+ (COStatsdController*)sharedStatsdController;

@property(readwrite) CGFloat percent;

@end
