#include "kinfo.h"

struct kinfo *
kinfo_create(void)
{
    struct kinfo *this = (struct kinfo *)xmalloc(sizeof(struct kinfo));
    memset(this, 0, sizeof(struct kinfo));
    return this;
}

void
kinfo_release(struct kinfo *this)
{
    free(this);
}

int
kinfo_get_proc_info(struct kinfo *this)
{
    unsigned int processor_count;
    processor_cpu_load_info_t cpu_load;
    mach_msg_type_number_t cpu_msg_count;
    host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processor_count, 
        (processor_info_array_t *)&cpu_load, &cpu_msg_count);
    this->processor_count = processor_count;

    unsigned long long user_time = 0;
    unsigned long long nice_time = 0;
    unsigned long long system_time = 0;
    unsigned long long idle_time = 0;
    unsigned long long total_time = 0;
    for (int i = 0; i < processor_count; i++) {
        user_time += cpu_load[i].cpu_ticks[CPU_STATE_USER];
        nice_time += cpu_load[i].cpu_ticks[CPU_STATE_NICE];
        system_time += cpu_load[i].cpu_ticks[CPU_STATE_SYSTEM];
        idle_time += cpu_load[i].cpu_ticks[CPU_STATE_IDLE];
    }
    total_time = user_time + nice_time + system_time + idle_time;

    this->user_period = user_time - this->user_time;
    this->nice_period = nice_time - this->nice_time;
    this->system_period = system_time - this->system_time;
    this->idle_period = idle_time - this->idle_time;
    this->total_period = total_time - this->total_time;
    this->user_time = user_time;
    this->nice_time = nice_time;
    this->system_time = system_time;
    this->idle_time = idle_time;
    this->total_time = total_time;

    vm_deallocate(mach_task_self(),
            (vm_address_t)cpu_load,
            (vm_size_t)(cpu_msg_count * sizeof(*cpu_load))
            );
    return 0;
}

int
kinfo_get_load_average(struct kinfo *this)
{
    getloadavg(this->loadavg, 3);
    return 0;
}

