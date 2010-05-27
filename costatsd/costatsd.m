#include "costatsd.h"

int
main(int argc, const char **argv)
{
    // parse option
    const char *cmd;

    if (argc <= 1) {
        cmd = "help";
    } else {
        argc--;
        argv++;
        cmd = *argv;
    }

    // run command
    struct cmd_struct cmds[] = {
        {"help", cmd_help},
        {"repair", cmd_repair},
        {"daemon", cmd_daemon},
        {"test", cmd_test},
    };

    for (int i = 0; i < ARRAY_SIZE(cmds); i++) {
        struct cmd_struct *p = cmds + i;
        if (strcmp(p->cmd, cmd))
            continue;
        return p->fn(argc, argv);
    }

    fprintf(stderr, "Unknown command: %s\n", cmd);
    return 0;
}
