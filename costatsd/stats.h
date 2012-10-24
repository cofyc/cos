#ifndef STATS_H
#define STATS_H

struct stats_struct {
    unsigned int total;
    unsigned int free;
    unsigned int inactive;
    unsigned int network_in;
    unsigned int network_out;
    float        cpu_user_percent;
    float        cpu_system_percent;
    float        cpu_idle_percent;
};

extern int stats_memory(struct stats_struct *stats);
extern int stats_network(struct stats_struct *stats);
extern int stats_cpu(struct stats_struct *stats);

#endif
