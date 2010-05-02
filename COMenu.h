#import <Cocoa/Cocoa.h>


@interface COMenu : NSObject {
}

+ (COMenu *)shared;

- (void)update;

@end