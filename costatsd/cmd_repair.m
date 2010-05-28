#include "costatsd.h"
#import <Foundation/Foundation.h>

int
cmd_repair(int argc, const char **argv)
{
    // this should run as root
    // Because, when it set setuid bit as non-root, then it
    // cannot set its onwer id and group id, even if as root.
    if (getuid() != 0) {
        if (setuid(0)) {
            die("unable to become root");
        }
    }
    
    NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];

    NSString *path =[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/costatsd"];

    NSFileManager *fileMgr =[NSFileManager defaultManager];

    NSDictionary *attrs =[fileMgr attributesOfItemAtPath: path error:nil];

    int status = 0;

    NSMutableDictionary *attrsToSet =[NSMutableDictionary dictionary];
    
    if (([attrs filePosixPermissions] & 04000) != 04000) {
        fprintf(stdout, "Reparing permission...");
        int permsToSet =[attrs filePosixPermissions] | 04000;
        [attrsToSet setObject: [NSNumber numberWithInt: permsToSet] forKey:NSFilePosixPermissions];
        
        if (![fileMgr setAttributes: attrsToSet ofItemAtPath: path error:nil]) {
            fprintf(stdout, "failed.\n", [path UTF8String]);
            status = -1;
        } else {
            fprintf(stdout, "ok.\n");
        }
    }
    
    [attrsToSet removeAllObjects];
    
    if ([attrs fileOwnerAccountID] !=[NSNumber numberWithInt:0]
        || [attrs fileGroupOwnerAccountID] !=[NSNumber numberWithInt:1]
        ) {
        fprintf(stdout, "Reparing owner id...");
        [attrsToSet setObject: [NSNumber numberWithInt: 0] forKey:NSFileOwnerAccountID];
        [attrsToSet setObject: [NSNumber numberWithInt: 1] forKey:NSFileGroupOwnerAccountID];
        
        NSError *error;
        if (![fileMgr setAttributes: attrsToSet ofItemAtPath: path error:&error]) {
            fprintf(stdout, "failed. <error: %s>\n", [path UTF8String], [[error domain] UTF8String]);
            status = -1;
        } else {
            fprintf(stdout, "ok.\n");
        }
    }

    [pool release];

    return status;
}
