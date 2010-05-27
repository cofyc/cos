#include "costatsd.h"
#include <unistd.h>

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
get_processes(struct kinfo_proc **procs, int *number)
{
	int					mib[4]	= { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    struct	kinfo_proc* info;
	size_t				length;
    int					level	= 3;
    
    if (sysctl(mib, level, NULL, &length, NULL, 0) < 0) return;
    if (!(info = malloc(length))) return;
    if (sysctl(mib, level, info, &length, NULL, 0) < 0) {
        free(info);
        return;
    }
	*procs = info;
	*number = length / sizeof(struct kinfo_proc);
}
int
cmd_daemon(int argc, const char **argv)
{
    const char *pid_file = "/var/run/costatsd.pid";
    const char *sock_path = "/var/run/costatsd.sock";

    pid_t pid;

    
    if (get_pid_from_file(pid_file, &pid) != 0) {
        if (set_pid_to_file(getpid(), pid_file) != 0) {
            return -1;
        }
    } else {
        warning("already a instance (%ld) is running", (long int)pid);
        info("killing %ld...", (long int)pid);  
        kill(pid, SIGTERM);
    }

	daemonize();

    return 0;
}
