#import "COAppController.h"
#import "COMenu.h"
#import "CORecorder.h"

@implementation COAppController

- (id)init
{   
    COMenu *menu = [[COMenu shared] init];
    [[CORecorder shared] initWithMenu:menu];
    return self;
}

@end