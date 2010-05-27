#import <Cocoa/Cocoa.h>


@interface COStatsdController : NSObject {
}

+ (COStatsdController*)sharedStatsdController;

- (CGFloat)getPercent;

@end
