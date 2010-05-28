#ifndef _STATS_H
#define _STATS_H

struct stats_struct {
    unsigned int total;
    unsigned int free;
    unsigned int inactive;
    unsigned int network_in;
    unsigned int network_out;
};

extern int stats_memory(struct stats_struct *stats);
extern int stats_network(struct stats_struct *stats);

#endif
