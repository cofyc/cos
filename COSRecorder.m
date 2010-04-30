#import "COSRecorder.h"

static COSRecorder *_sharedRecorder = nil;

@implementation COSRecorder

+ (COSRecorder *)shared
{
	if (!_sharedRecorder) {
		_sharedRecorder = [self alloc];
	}
	return _sharedRecorder;
}

- (id)initWithMenu:(COSMenu *)menu
{
	[self init];
	_menu = menu;
	_checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(record:) userInfo:nil repeats:YES];
	return self;
}

- (BOOL)record:(NSTimer *)timer
{
	NSLog(@"starting record...");
	NSLog(@"ending record...");
	[_menu update];
	return TRUE;
}

@end