#include "costatsd.h"

int
cmd_help(int argc, const char **argv)
{
    printf("Usage: costatsd COMMAND [ARGS]\n"
           "\n"
           "Aailable commands:\n"
           "    test    run test code\n"
           "    repair  do self repair\n"
           "    help    show this help info\n"
           "    daemon  run as a daemon\n");
    printf("\n");
    return 0;
}
