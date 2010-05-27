#ifndef _WRAPPER_H
#define _WRAPPER_H

/* Usage */
void usage(const char *err);
void die(const char *err, ...);
int error(const char *err, ...);
void warning(const char *warn, ...);
void info(const char *info, ...);

/* String */
char *xstrdup(const char *str);

/* Memory */
void *xmalloc(size_t size);

/* Misc. */
ssize_t xread(int fd, void *buf, size_t len);
ssize_t xwrite(int fd, const void *buf, size_t len);

#endif
