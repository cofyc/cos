#import "COStatsdController.h"
#import "COUtility.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include "costatsd/stats.h"

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

static void
AcceptCallback(CFSocketRef s,
               CFSocketCallBackType type,
               CFDataRef address,
               const void *data,
               void *info)
{
    CFDataRef newData;
    assert(s != NULL);
    assert(type == kCFSocketDataCallBack);
    
    newData = (CFDataRef)data;
    assert(newData != NULL);
    assert(CFGetTypeID(newData) == CFDataGetTypeID());
    
    COStatsdController *statsdController = (__bridge COStatsdController *)info;
    
    if (CFDataGetLength(newData) == 0) {
        // End of data stream; the server is dead.
        NSLog(@"ConnectionGotData: Server died unexpectedly.");
    } else {
        static CFMutableDataRef fBufferedPackets = NULL;
        if (fBufferedPackets == NULL) {
            fBufferedPackets = CFDataCreateMutable(NULL, 0);
        }
        
        struct stats_struct *stats;
        
        // We have new data from the server.  Appending to our buffer.
        NSLog(@"length:%ld", CFDataGetLength(newData));
        CFDataAppendBytes(fBufferedPackets, CFDataGetBytePtr(newData), CFDataGetLength(newData));
        
        // Now see if there are any complete packets in the buffer; and, 
        // if so, deliver them to the client.
        do {
            if (CFDataGetLength(fBufferedPackets) < sizeof(struct stats_struct) ) {
                // Not enough data for the packet header; we're done.
                break;
            }
            stats = (struct stats_struct *)CFDataGetBytePtr(fBufferedPackets);
            
            // Tell the client about the packet.
            [statsdController parseStats:stats];
            
            CFDataDeleteBytes(fBufferedPackets, CFRangeMake(0, CFDataGetLength(fBufferedPackets)));
        } while (true);
    }
}


@implementation COStatsdController

@synthesize percent, cpu_user_percent, cpu_system_percent, cpu_idle_percent, network_in, network_out;

- (id)init
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"costatsd" ofType:nil];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSDictionary *atts = [fileMgr attributesOfItemAtPath:path error:nil];
    
    OSStatus myStatus;
    
    if (([atts filePosixPermissions] & 04000) != 04000
        || [atts fileOwnerAccountID] != @0
        || [atts fileGroupOwnerAccountID] != @1
        ) {
        
        AuthorizationRef myAuthorizationRef;
        AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &myAuthorizationRef);
        
        AuthorizationFlags myFlags = kAuthorizationFlagDefaults
            | kAuthorizationFlagInteractionAllowed
            | kAuthorizationFlagPreAuthorize
            | kAuthorizationFlagExtendRights
        ;

        AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
        AuthorizationRights myRights = {1, &myItems};
        myStatus = AuthorizationCopyRights(myAuthorizationRef, &myRights, kAuthorizationEmptyEnvironment, myFlags, NULL );
        if (myStatus != errAuthorizationSuccess) {
            [[NSApplication sharedApplication] terminate:self];
        }
        
        FILE *myCommunicationPipe = NULL;
        char *myArguments[] = {
            "repair",
        };
        
        myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef, [path UTF8String], kAuthorizationFlagDefaults, myArguments, &myCommunicationPipe);
        
        if (myStatus != errAuthorizationSuccess) {
            [[NSApplication sharedApplication] terminate:self];
        }
        
//        NSFileHandle *fileHandle = [[NSFileHandle alloc] initWithFileDescriptor: fileno(myCommunicationPipe)];
//        NSLog(@"costatsd: %@", [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding]);
        
        AuthorizationFree(myAuthorizationRef, kAuthorizationFlagDefaults);
    }
    
    NSLog(@"starting daemon...");
    NSMutableArray *daemonArguments = [NSMutableArray array];
    [daemonArguments addObject:@"daemon"];
    
    NSTask* task = [NSTask launchedTaskWithLaunchPath:path arguments:daemonArguments];
    [task waitUntilExit];
    NSLog(@"ok.");

    NSLog (@"connecting...");
    const char *sock_path = "/var/run/costatsd.sock";
    fd = client_connect(sock_path);
    
    NSLog(@"fd:%d", fd);
    CFSocketContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    socketRef = CFSocketCreateWithNative(NULL,
                                        fd,
                                        kCFSocketDataCallBack,
                                        AcceptCallback,
                                        &context
                                        );
    CFRunLoopSourceRef rls = CFSocketCreateRunLoopSource(NULL, socketRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    return self;
}

- (void)parseStats:(struct stats_struct *)stats
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"inactiveAsFree"]) {
        self.percent = (double)(stats->total - stats->free - stats->inactive) / stats->total;
    } else {
        self.percent = (double)(stats->total - stats->free) / stats->total;
    }
    self.percent = [COUtility round:self.percent withPrecision:2];
    NSLog(@"mem_percent:%f", self.percent);
    
    self.cpu_user_percent = (double)stats->cpu_user_percent;
    self.cpu_system_percent = (double)stats->cpu_system_percent;
    self.cpu_idle_percent = (double)stats->cpu_idle_percent;
    self.cpu_user_percent = [COUtility round:self.cpu_user_percent withPrecision:2];
    self.cpu_system_percent = [COUtility round:self.cpu_system_percent withPrecision:2];
    self.cpu_idle_percent = [COUtility round:self.cpu_idle_percent withPrecision:2];
    NSLog(@"user:%f sys:%f idle: %f", self.cpu_user_percent, self.cpu_system_percent, self.cpu_idle_percent);
    self.network_in = (double)stats->network_in;
    self.network_out = (double)stats->network_out;
    NSLog(@"network_in:%f, network_out:%f", self.network_in, self.network_out);
}

- (void)stats
{
    char *cmd = "stats";
    write(fd, cmd, strlen(cmd));
}

@end
