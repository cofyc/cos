#ifndef KINFO_H
#define KINFO_H

#include "wrapper.h"

#include <dirent.h>
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
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <unistd.h>

/* Kernel Info Struct */
struct kinfo {
    unsigned int processor_count;
    double loadavg[3];
    unsigned long long int user_time;
    unsigned long long int nice_time;
    unsigned long long int system_time;
    unsigned long long int idle_time;
    unsigned long long int total_time;
    unsigned long long int user_period;
    unsigned long long int nice_period;
    unsigned long long int system_period;
    unsigned long long int idle_period;
    unsigned long long int total_period;
};

struct kinfo *kinfo_create(void);
void kinfo_release(struct kinfo *this);
int kinfo_get_proc_info(struct kinfo *this);
int kinfo_get_load_average(struct kinfo *this);
#endif
