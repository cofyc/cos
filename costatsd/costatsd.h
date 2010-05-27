#ifndef _COSTATSD_H
#define _COSTATSD_H

#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

struct cmd_struct {
    const char *cmd;
    int (*fn) (int, const char **);
};

int cmd_repair(int argc, const char **argv);
int cmd_help(int argc, const char **argv);
int cmd_daemon(int argc, const char **argv);
int cmd_test(int argc, const char **argv);

#endif