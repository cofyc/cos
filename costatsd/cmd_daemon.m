#include "costatsd.h"
#include <unistd.h>
#include <sys/sysctl.h>
#include <sys/socket.H>
#include <sys/un.h>

#define QUEUE_LEN 5

static void
daemonize(void)
{
    switch (fork()) {
        case 0:
            break;
        case -1:
            die("fork failed");
        default:
            exit(0);
    }
    if (setsid() == -1)
        die("setsid failed");
    close(0);
    close(1);
    close(2);
}

static int
set_pid_to_file(const pid_t pid, const char *pid_file)
{
    FILE *fp;
    if ((fp = fopen(pid_file, "w")) == NULL) {
        return error("cannot open the pid file '%s'", pid_file);
    }

    if (fprintf(fp, "%ld\n", (long int)pid) < 0 || fclose(fp) != 0)
        return error("failed to write pid file '%s'", pid_file);

    return 0;
}

static int
get_pid_from_file(const char *pid_file, pid_t *pid)
{
    long int pid_num;
    FILE *fp;

    if ((fp = fopen(pid_file, "r")) == NULL) {
        return error("cannot open the pid file '%s'", pid_file);
    }

    if (fscanf(fp, "%ld\n", &pid_num) < 0)
        return error("failed to read the pid file '%s'", pid_file);

    *pid = (pid_t)pid_num;

    fclose(fp);

    return 0;
}

static int
remove_pid_file(const char *pid_file)
{
    return unlink(pid_file);
}

static void
processes_get(struct kinfo_proc **procs, int *count)
{
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    struct kinfo_proc *info;
    size_t length;
    int level = 3;

    if (sysctl(mib, level, NULL, &length, NULL, 0) < 0)
        return;

    if (!(info = malloc(length)))
        return;
    if (sysctl(mib, level, info, &length, NULL, 0) < 0) {
        free(info);
        return;
    }

    *procs = info;
    *count = length / sizeof(struct kinfo_proc);
}

static bool
process_exists(pid_t pid)
{
    bool does_exist = false;
    int count = 0;
    struct kinfo_proc *info = NULL;

    processes_get(&info, &count);

    for (int i = 0; i < count; i++) {
        pid_t this_pid = info[i].kp_proc.p_pid;
        if (pid == this_pid) {
            does_exist = true;
            break;
        }
    }

    free(info);

    return does_exist;
}

static void
serve_handle(int connection, struct sockaddr *addr, int addrlen)
{
    const char *test = "test string";
    xwrite(connection, test, strlen(test));
}

static int
serve_loop(int fd)
{
    int connection;
    struct sockaddr_un un;
    unsigned int len;
    for (;;) {
        connection = accept(fd, (struct sockaddr *)&un, &len);
        if (connection < 0) {
            switch (errno) {
                case EAGAIN:
                case EINTR:
                case ECONNABORTED:
                    continue;
                default:
                    die("accept returned");
            }
        }
        serve_handle(connection, (struct sockaddr *)&un, len);
    }
}

static int
serve(const char *sock_path)
{
    int fd;
    int len;
    struct sockaddr_un un;

    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        return -1;
    }

    unlink(sock_path); 

    memset(&un, 0, sizeof(un));
    un.sun_family = AF_UNIX;
    strcpy(un.sun_path, sock_path);
    len = OFFSET_OF(struct sockaddr_un, sun_path) + strlen(un.sun_path);
    
    if (bind(fd, (struct sockaddr *)&un, len) < 0) {
        return -2;
    } 
    
    if (listen(fd, QUEUE_LEN) < 0) {
        return -3;
    }
    
    return serve_loop(fd);
}

int
cmd_daemon(int argc, const char **argv)
{
    const char *pid_file = "/var/run/costatsd.pid";
    const char *sock_path = "/var/run/costatsd.sock";

    pid_t pid;

    // kill old one
    if (get_pid_from_file(pid_file, &pid) == 0 && process_exists(pid)) {
        warning("already a instance (%ld) is running", (long int)pid);
        info("killing %ld...", (long int)pid);
        kill(pid, SIGTERM);
    }

    daemonize();

    if (set_pid_to_file(getpid(), pid_file) != 0) {
        return -1;
    }

    if (serve(sock_path) != 0) {
        return -2;
    }

    return 0;
}
