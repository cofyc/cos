#include "stats.h"
#include "kinfo.h"

static struct kinfo *kinfo = NULL;

int
stats_cpu(struct stats_struct *stats)
{
    if (kinfo == NULL) {
        kinfo = kinfo_create();
    }
    kinfo_get_proc_info(kinfo);
    stats->cpu_user_percent = (double)kinfo->user_period / kinfo->total_period;
    stats->cpu_system_percent = (double)kinfo->system_period / kinfo->total_period;
    stats->cpu_idle_percent = (double)kinfo->idle_period / kinfo->total_period;
    return 0;
}
