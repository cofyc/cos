/*
 * Various trivial helper wrappers around standard functions
 *
 * Borrowed from git, etc.
 */

static void
report(const char *prefix, const char *err, va_list params)
{
    char msg[4096];
    vsnprintf(msg, sizeof(msg), err, params);
    fprintf(stderr, "%s%s\n", prefix, msg);
}

void
usage(const char *err, ...)
{
    va_list params;
    va_start(params, err);
    report("usage: ", err, params);
    exit(129);
    va_end(params);
}

void
die(const char *err, ...)
{
    va_list params;

    va_start(params, err);
    report("fatal: ", err, params);
    exit(128);
    va_end(params);
}

int
error(const char *err, ...)
{
    va_list params;

    va_start(params, err);
    report("error: ", err, params);
    va_end(params);
    return -1;
}

void
info(const char *info, ...)
{
    va_list params;

    va_start(params, info);
    report("info: ", info, params);
    va_end(params);
}

void
warning(const char *warn, ...)
{
    va_list params;

    va_start(params, warn);
    report("warning: ", warn, params);
    va_end(params);
}

void *
xmalloc(size_t size)
{
    void *ret = malloc(size);
    if (!ret && !size)
        ret = malloc(1);
    if (!ret) {
        ret = malloc(size);
        if (!ret && !size)
            ret = malloc(1);
        if (!ret)
            die("Out of memory, malloc failed");
    }

    return ret;
}

/*
 * xread() is the same a read(), but it automatically restarts read()
 * operations with a recoverable error (EAGAIN and EINTR). xread()
 * DOES NOT GUARANTEE that "len" bytes is read even if the data is available.
 */
ssize_t
xread(int fd, void *buf, size_t len)
{
    ssize_t nr;
    while (1) {
        nr = read(fd, buf, len);
        if ((nr < 0) && (errno == EAGAIN || errno == EINTR))
            continue;
        return nr;
    }
}

/*
 * xwrite() is the same a write(), but it automatically restarts write()
 * operations with a recoverable error (EAGAIN and EINTR). xwrite() DOES NOT
 * GUARANTEE that "len" bytes is written even if the operation is successful.
 */
ssize_t
xwrite(int fd, const void *buf, size_t len)
{
    ssize_t nr;
    while (1) {
        nr = write(fd, buf, len);
        if ((nr < 0) && (errno == EAGAIN || errno == EINTR))
            continue;
        return nr;
    }
}

char *
xstrdup(const char *str)
{
    char *ret = strdup(str);
    if (!ret) {
        ret = strdup(str);
        if (!ret)
            die("Out of memory, strdup failed");
    }
    return ret;
}

/*
 * xmemdup() allocates (size + 1) bytes of memory, duplicates "size" bytes of 
 * "data" to the allocated memory, zero terminates the allocated memory,
 * and returns a pointer to the allocated memory. If the allocation fails,
 * the program dies.
 */
void *
xmemdup(const void *data, size_t size)
{
    void *ret;
    if (size + 1 < size)
        die("Data too large to fit into virtual memory space.");
    ret = xmalloc(size + 1);
    ((char*)ret)[size] = 0;
    return memcpy(ret, data, size);
}

char *
xstrndup(const char *str, size_t len)
{
    char *p = memchr(str, '\0', len);
    return xmemdup(str, p ? p - str : len);
}
