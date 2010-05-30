#include "stats.h"

int
stats_cpu(struct stats_struct *stats)
{
    stats->cpu_user_percent = 0.3;
    stats->cpu_sys_percent = 0.1;
    stats->cpu_idle_percent = 1 - stats->cpu_user_percent - stats->cpu_sys_percent;
    return 0;
}
