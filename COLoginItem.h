#import <Cocoa/Cocoa.h>


@interface COLoginItem : NSObject {

}

+ (BOOL)willStartAtLogin:(NSURL *)itemURL;

+ (void)setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;

@end
