#import "COSMemoryStats.h"

#include <mach/host_info.h>
#include <mach/mach_host.h>
#include <mach/mach_init.h>
#include <mach/mach_interface.h>
#include <mach/mach_port.h>
#include <mach/mach_traps.h>
#include <mach/mach_types.h>
#include <mach/machine.h>
#include <mach/processor_info.h>
#include <mach/shared_region.h>
#include <mach/task.h>
#include <mach/thread_act.h>
#include <mach/time_value.h>
#include <mach/vm_map.h>

@implementation COSMemoryStats

- (NSInteger)getMaxMem
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    return (NSInteger)hostInfo.max_mem;
}

@end
