#include "costatsd.h"
#include "stats.h"
#include <unistd.h>
#include <sys/sysctl.h>
#include <sys/socket.H>
#include <sys/un.h>
#include <sys/stat.h>

static void
daemonize(void)
{
    umask(0);

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

    if (chdir("/") < 0)
        die("chdir failed");

    close(0);
    close(1);
    close(2);

    // if any standard file descriptor is missing open it to /dev/null */
    int fd = open("/dev/null", O_RDWR, 0); 
    while (fd != -1 && fd < 2)
        fd = dup(fd);
    if (fd == -1) 
        die("open /dev/null or dup failed");
}

static int
set_pid_to_file(const pid_t pid, const char *pid_file)
{
    FILE *fp;
    if ((fp = fopen(pid_file, "w")) == NULL) {
        return error("cannot open the pid file '%s'", pid_file);
    }

    if (fprintf(fp, "%ld", (long int)pid) < 0 || fclose(fp) != 0)
        return error("failed to write pid file '%s'", pid_file);

    return 0;
}

static int
get_pid_from_file(const char *pid_file, pid_t *pid)
{
    long int pid_num;
    FILE *fp;

    if ((fp = fopen(pid_file, "r")) == NULL)
        return -1;

    if (fscanf(fp, "%ld", &pid_num) < 0)
        return -2;

    *pid = (pid_t)pid_num;

    fclose(fp);

    return 0;
}

static void
process_get(struct kinfo_proc **procs, int *count)
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

    process_get(&info, &count);

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
    char msg[4096];
    size_t msg_len;
    while (1) {
        char cmd[140];
        ssize_t len = xread(connection, cmd, sizeof(cmd));
        if (!len)
            break;
        if (len < 0) {
            close(connection);
            return;
        }
        cmd[len] = '\0';
        if (!strcmp(cmd, "stats")) {
            struct stats_struct stats;
            stats_memory(&stats);
            stats_cpu(&stats);
            xwrite(connection, &stats, sizeof(stats));
        } else if (!strcmp(cmd, "exit")) {
            kill(getpid(), SIGTERM);
        } else {
            msg_len = snprintf(msg, sizeof(msg), "Unknown command: %s\n", cmd);
            xwrite(connection, msg, msg_len);
        }
    }
    close(connection);
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
    return 0;
}

static int
serve(const char *sock_path)
{
    int fd;
    int len;
    struct stat tstat;
    struct sockaddr_un un;
    int access_mask = 0666;
    int old_umask;

    if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        return -1;
    }

    /*
     * Clean up a previous socket file if we left it around.
     */
    if (lstat(sock_path, &tstat) == 0) {
        if (S_ISSOCK(tstat.st_mode))
            unlink(sock_path); 
    }

    memset(&un, 0, sizeof(un));
    un.sun_family = AF_UNIX;
    strncpy(un.sun_path, sock_path, sizeof(un.sun_path) - 1);
    len = OFFSET_OF(struct sockaddr_un, sun_path) + strlen(un.sun_path);
    old_umask = umask(~(access_mask&0777)); 
    if (bind(fd, (struct sockaddr *)&un, len) < 0) {
        close(fd);
        umask(old_umask);
        return error("bind() faild");
    } 

    umask(old_umask);

    if (listen(fd, 5) < 0) {
        close(fd);
        return error("listen() failed");
    }
    
    return serve_loop(fd);
}

typedef void (*sighandler_func)(int);

static void
remove_pid_file_on_signal(int signo)
{
    unlink(pid_file);
    exit(0);
}

static void
sighandler_push_common(sighandler_func f)
{
    signal(SIGINT, f);
    signal(SIGHUP, f);
    signal(SIGTERM, f);
    signal(SIGQUIT, f);
    signal(SIGPIPE, f);
}

int
cmd_daemon(int argc, const char **argv)
{
    if (getuid() != 0) {
        if (setuid(0)) {
            die("unable to become root (should run as root)");
        }
    }

    pid_t pid;

    // kill old one
    if (get_pid_from_file(pid_file, &pid) == 0 && process_exists(pid)) {
        warning("already a instance (%ld) is running", (long int)pid);
        info("killing %ld...", (long int)pid);
        kill(pid, SIGTERM);
    }

    daemonize();

    sighandler_push_common(remove_pid_file_on_signal);

    if (set_pid_to_file(getpid(), pid_file) != 0) {
        return -1;
    }

    if (serve(sock_path) != 0) {
        return -2;
    }

    return 0;
}
