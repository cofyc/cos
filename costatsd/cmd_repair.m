#include "costatsd.h"
#import <Foundation/Foundation.h>

int
cmd_repair(int argc, const char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    fprintf(stdout, "Reparing...");
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/costatsd"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSDictionary *atts = [fileMgr attributesOfItemAtPath:path error:nil];

    int status = 0;
    
    if (([atts filePosixPermissions] & 04000) != 04000
        || [atts fileGroupOwnerAccountID] != [NSNumber numberWithInt:0]
        || [atts fileGroupOwnerAccountID] != [NSNumber numberWithInt:0]
        ) {
        NSMutableDictionary *attrsToSet = [NSMutableDictionary dictionary];
        int permsToSet = [atts filePosixPermissions] | 04000;
        [attrsToSet setObject:[NSNumber numberWithInt:permsToSet] forKey:NSFilePosixPermissions];
        [attrsToSet setObject:[NSNumber numberWithInt:0] forKey:NSFileOwnerAccountID];
        [attrsToSet setObject:[NSNumber numberWithInt:0] forKey:NSFileGroupOwnerAccountID];
        
        if (![fileMgr setAttributes:attrsToSet ofItemAtPath:path error:nil]) {
            fprintf(stdout, "failed. <path: %s>\n", [path UTF8String]);
            status = -1;
        } else {            
            fprintf(stdout, "ok.\n");
        }
        
    } else {
        fprintf(stdout, "already ok.\n");
    }

    [pool release];
    
    return status;
}
