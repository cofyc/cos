#import "COStatsdController.h"

static COStatsdController *_sharedStatsdController= nil;

@implementation COStatsdController

+ (COStatsdController*)sharedStatsdController
{
    if (!_sharedStatsdController) {
        _sharedStatsdController = [[self alloc] init];
    }
    return _sharedStatsdController;
}

- (CGFloat)getPercent
{
    
    return 0.4;
}

@end
