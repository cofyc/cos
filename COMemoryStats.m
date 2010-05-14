#import "COMemoryStats.h"
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/mach_init.h>
#import <mach/mach_interface.h>
#import <mach/mach_port.h>
#import <mach/mach_traps.h>
#import <mach/mach_types.h>
#import <mach/machine.h>
#import <mach/processor_info.h>
#import <mach/shared_region.h>
#import <mach/task.h>
#import <mach/thread_act.h>
#import <mach/time_value.h>
#import <mach/vm_map.h>


@implementation COMemoryStats

static CGFloat percent;

+ (CGFloat)getPercent
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
    NSInteger inactiveMem = pageSize * vm_stat.inactive_count / 1024;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"inactiveAsFree"]) {
        percent = (CGFloat) (totalMem - freeMem - inactiveMem) / totalMem;
    } else {
        percent = (CGFloat) (totalMem - freeMem) / totalMem;
    }
    return percent;
}

@end
