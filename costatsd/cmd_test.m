#include "costatsd.h"
#include <sys/socket.h>
#include <sys/un.h>

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
    int fd;
    if ((fd = client_connect(sock_path)) < 0) {
        die("failed to connect to sock");
    }

    char buf[1024];

    char *cmds[] = {
        "stats",
        "anystring",
    };

    ssize_t len;

    for (int i = 0; i < ARRAY_SIZE(cmds); i++) {
        char *cmd = *(cmds + i);
        xwrite(fd, cmd, strlen(cmd));
        len = xread(fd, buf, sizeof(buf));
        buf[len] = '\0';
        printf("%s", buf);
    }
    close(fd);
    return 0;
}
