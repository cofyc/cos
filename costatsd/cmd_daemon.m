#include "costatsd.h"

static void
daemonize(void)
{
	switch (fork()) {
		case 0:
			break;
		case -1:
			die_errno("fork failed");
		default:
			exit(0);
	}
	if (setsid() == -1)
		die_errno("setsid failed");
	close(0);
	close(1);
	close(2);
}

int
cmd_daemon(int argc, const char **argv)
{

    return 0;
}
