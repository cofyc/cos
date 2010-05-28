#ifndef _WRAPPER_H
#define _WRAPPER_H

/* Usage */
void usage(const char *err);
void die(const char *err, ...);
int error(const char *err, ...);
void warning(const char *warn, ...);
void info(const char *info, ...);

/* X-series */
char *xstrdup(const char *str);
char *xstrndup(const char *str, size_t len);
void *xmalloc(size_t size);
void *xmemdup(const void *data, size_t size);
ssize_t xread(int fd, void *buf, size_t len);
ssize_t xwrite(int fd, const void *buf, size_t len);

#endif
