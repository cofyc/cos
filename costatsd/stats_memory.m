#include "stats.h"

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

int
stats_memory(struct stats_struct *stats)
{
    host_basic_info_data_t info_host;
    mach_msg_type_number_t info_count;

    info_count = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t) & info_host, &info_count);
    stats->total = info_host.max_mem / 1024;

    vm_size_t page_size;
    host_page_size(mach_host_self(), &page_size);

    vm_statistics_data_t vm_stat;
    host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t) & vm_stat, &info_count);

    stats->free = page_size * vm_stat.free_count / 1024;
    stats->inactive = page_size * vm_stat.inactive_count / 1024;

    return 0;
}
