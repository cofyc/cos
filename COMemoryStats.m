#import "COMemoryStats.h"


@implementation COMemoryStats

static CGFloat percent;

+ (CGFloat)getPercent;
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    vm_size_t pageSize;
    host_page_size( mach_host_self(  ), &pageSize );
    
    // Unit: KB
    NSInteger totalMem = hostInfo.max_mem / 1024;
    vm_statistics_data_t     vm_stat;
    host_statistics( mach_host_self(  ), HOST_VM_INFO,
                    ( host_info_t ) & vm_stat, &infoCount );
    NSInteger freeMem = pageSize * vm_stat.free_count / 1024;
    percent = (CGFloat) (totalMem - freeMem) / totalMem;
    return percent;
}

@end