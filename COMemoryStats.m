#import "COMemoryStats.h"



@implementation COMemoryStats

- (NSInteger)getMaxMem
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    return (NSInteger)hostInfo.max_mem;
}

@end
