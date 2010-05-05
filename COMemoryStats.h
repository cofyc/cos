#import <Cocoa/Cocoa.h>


@interface COMemoryStats : NSObject {
}

+ (CGFloat)getPercentWithInactiveAsFree:(BOOL)inactiveAsFree;

@end
