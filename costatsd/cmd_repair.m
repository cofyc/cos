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

    NSString *path =[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/costatsd"];

    NSFileManager *fileMgr =[NSFileManager defaultManager];

    NSDictionary *attrs =[fileMgr attributesOfItemAtPath: path error:nil];

    int status = 0;

    NSMutableDictionary *attrsToSet =[NSMutableDictionary dictionary];
    
    if (([attrs filePosixPermissions] & 04000) != 04000) {
        fprintf(stdout, "Reparing permission...");
        int permsToSet =[attrs filePosixPermissions] | 04000;
        attrsToSet[NSFilePosixPermissions] = @(permsToSet);
        
        if (![fileMgr setAttributes: attrsToSet ofItemAtPath: path error:nil]) {
            fprintf(stdout, "%s failed.\n", [path UTF8String]);
            status = -1;
        } else {
            fprintf(stdout, "ok.\n");
        }
    }
    
    [attrsToSet removeAllObjects];
    
    if ([attrs fileOwnerAccountID] != @0
        || [attrs fileGroupOwnerAccountID] != @1
        ) {
        fprintf(stdout, "Reparing owner id...");
        attrsToSet[NSFileOwnerAccountID] = @0;
        attrsToSet[NSFileGroupOwnerAccountID] = @1;
        
        NSError *error;
        if (![fileMgr setAttributes: attrsToSet ofItemAtPath: path error:&error]) {
            fprintf(stdout, "%s failed. <error: %s>\n", [path UTF8String], [[error domain] UTF8String]);
            status = -1;
        } else {
            fprintf(stdout, "ok.\n");
        }
    }

    return status;
}
