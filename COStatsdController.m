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

- (id)init
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"costatsd" ofType:nil];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSDictionary *atts = [fileMgr attributesOfItemAtPath:path error:nil];
    
    OSStatus myStatus;
    
    if (([atts filePosixPermissions] & 04000) != 04000
        || [atts fileGroupOwnerAccountID] != [NSNumber numberWithInt:0]
        || [atts fileGroupOwnerAccountID] != [NSNumber numberWithInt:0]
        ) {
        
        AuthorizationRef myAuthorizationRef;
        myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &myAuthorizationRef);
        
        AuthorizationFlags myFlags = kAuthorizationFlagDefaults
            | kAuthorizationFlagInteractionAllowed
            | kAuthorizationFlagPreAuthorize
            | kAuthorizationFlagExtendRights
        ;
        
        AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
        AuthorizationRights myRights = {1, &myItems};
        myStatus = AuthorizationCopyRights (myAuthorizationRef,&myRights, kAuthorizationEmptyEnvironment, myFlags, NULL );
        if (myStatus |= errAuthorizationSuccess) {
            
        }
        
        FILE *myCommunicationPipe = NULL;
        char *myArguments[] = {
            "repair",
        };
        
        myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef, [path UTF8String], kAuthorizationFlagDefaults, myArguments, &myCommunicationPipe);
        
        if (myStatus == errAuthorizationSuccess) {
            NSFileHandle *fileHandle = [[NSFileHandle alloc] initWithFileDescriptor: fileno(myCommunicationPipe)];
            NSLog(@"costatsd: %@", [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding]);
        }
        
        AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
    }
    
    
    NSLog(@"starting daemon...");
    NSMutableArray *daemonArguments = [NSMutableArray array];
    [daemonArguments addObject:@"daemon"];
    
    NSTask* task = [NSTask launchedTaskWithLaunchPath:path arguments:daemonArguments];
    [task waitUntilExit];
    NSLog(@"ok.");
    
    return self;
}

- (CGFloat)getPercent
{
    
    return 0.4;
}



@end
