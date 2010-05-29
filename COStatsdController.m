#import "COStatsdController.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

static int
client_connect(const char *sock_path)
{
    int fd;
    int err;
    struct sockaddr_un un;
    
    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        err = -1;
        goto errorout;
    }
    
    memset(&un, 0, sizeof(un));
    un.sun_family = AF_UNIX;
    strcpy(un.sun_path, sock_path);
    if (connect(fd, (struct sockaddr *)&un, sizeof(struct sockaddr_un)) < 0) {
        err = -2;
        goto errorout;
    }
    
    return fd;
    
errorout:
    close(fd);
    return err;
}

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


    [self testConnection];
    
    return self;
}

- (void)testConnection
{
    NSLog (@"connecting...");
    const char *sock_path = "/var/run/costatsd.sock";
    
    int fd;
    
    char buf[4096];
    
    fd = client_connect(sock_path);
    
    int nr;
    char *cmd = "stats";
    nr = write(fd, cmd, sizeof(cmd));
    
    int len;
    nr = read(fd, buf, sizeof(buf));
    
    NSString *
    
    NSLog(@"costatsd: %@", [NSString stringWithCString:buf]);
}

- (CGFloat)getPercent
{
    return 0.4;
}

@end
