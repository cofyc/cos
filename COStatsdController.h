#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface COStatsdController : NSObject {
}

+ (COStatsdController*)sharedStatsdController;

- (CGFloat)getPercent;

@end
