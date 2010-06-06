#include "costatsd.h"
#include <sys/socket.h>
#include <sys/un.h>
#include "stats.h"
#include <unistd.h>

static int
client_connect(const char *sock_path)
{
    int fd;
    int len;
    int err;
    struct sockaddr_un un;

    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        err = -1;
        goto errorout;
    }

    memset(&un, 0, sizeof(un));
    un.sun_family = AF_UNIX;
    strcpy(un.sun_path, sock_path);
    len = OFFSET_OF(struct sockaddr_un, sun_path) + strlen(un.sun_path);
    if (connect(fd, (struct sockaddr *)&un, len) < 0) {
        err = -2;
        goto errorout;
    }

    return fd;

errorout:
    close(fd);
    return err;
}

int
cmd_test(int argc, const char **argv)
{
    struct stats_struct stats;
    stats_network(&stats);
    sleep(10);
    stats_network(&stats);
    printf("network_in: %u\n", stats.network_in);
    printf("network_out: %u\n", stats.network_out);
    return 0;

    int fd;
    if ((fd = client_connect(sock_path)) < 0) {
        die("failed to connect to sock");
    }

    char buf[1024];

    char *cmds[] = {
        "stats",
    };

    ssize_t len;

    for (int i = 0; i < ARRAY_SIZE(cmds); i++) {
        char *cmd = *(cmds + i);
        xwrite(fd, cmd, strlen(cmd));
        if (!strcmp(cmd, "stats")) {
            struct stats_struct stats;
            len = xread(fd, &stats, sizeof(stats));
            printf("total: %u\n", stats.total);
            printf("inactive: %u\n", stats.inactive);
            printf("free: %u\n", stats.free);
            printf("network_in: %u\n", stats.network_in);
            printf("network_out: %u\n", stats.network_out);
        } else {
            len = xread(fd, buf, sizeof(buf));
            buf[len] = '\0';
            printf("%s", buf);
        }
    }
    close(fd);
    return 0;
}
