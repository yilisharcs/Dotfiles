#define _GNU_SOURCE
#include <dlfcn.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <stdarg.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>

static const char* redirect(const char* path, char* buffer, size_t size) {
    if (!path) return NULL;

    // We only care about config.json
    const char* filename = strrchr(path, '/');
    filename = (filename) ? filename + 1 : path;

    if (strcmp(filename, "config.json") == 0) {
        // If it's already in .config, don't redirect
        if (strstr(path, "/.config/")) return NULL;

        // If it's absolute but not in the Nix store, don't redirect
        if (path[0] == '/' && !strstr(path, "/nix/store/")) return NULL;

        const char* home = getenv("HOME");
        const char* xdg = getenv("XDG_CONFIG_HOME");

        buffer[0] = '\0';
        if (xdg && xdg[0] == '/') {
            if (strlen(xdg) + 25 > size) return NULL;
            strcpy(buffer, xdg);
            strcat(buffer, "/Sonic3AIR/config.json");
        } else if (home) {
            if (strlen(home) + 30 > size) return NULL;
            strcpy(buffer, home);
            strcat(buffer, "/.config/Sonic3AIR/config.json");
        } else {
            return NULL;
        }

        return buffer;
    }
    return NULL;
}

// Macro to wrap standard file-opening and existence functions
#define WRAP_OPEN(func)                                    \
    int func(const char *path, int flags, ...) {           \
        static int (*real)(const char *, int, ...) = NULL; \
        if (!real) real = dlsym(RTLD_NEXT, #func);         \
        char buf[PATH_MAX];                                \
        const char* p = redirect(path, buf, sizeof(buf));  \
        mode_t mode = 0;                                   \
        if (flags & O_CREAT) {                             \
            va_list args;                                  \
            va_start(args, flags);                         \
            mode = va_arg(args, mode_t);                   \
            va_end(args);                                  \
        }                                                  \
        return real(p ? p : path, flags, mode);            \
    }

#define WRAP_FOPEN(func)                                         \
    FILE* func(const char *path, const char *mode) {             \
        static FILE* (*real)(const char *, const char *) = NULL; \
        if (!real) real = dlsym(RTLD_NEXT, #func);               \
        char buf[PATH_MAX];                                      \
        const char* p = redirect(path, buf, sizeof(buf));        \
        return real(p ? p : path, mode);                         \
    }

#define WRAP_ACCESS(func)                                 \
    int func(const char *path, int mode) {                \
        static int (*real)(const char *, int) = NULL;     \
        if (!real) real = dlsym(RTLD_NEXT, #func);        \
        char buf[PATH_MAX];                               \
        const char* p = redirect(path, buf, sizeof(buf)); \
        return real(p ? p : path, mode);                  \
    }

#define WRAP_XSTAT(func)                                             \
    int func(int ver, const char *path, struct stat *stat_buf) {     \
        static int (*real)(int, const char *, struct stat *) = NULL; \
        if (!real) real = dlsym(RTLD_NEXT, #func);                   \
        char buf[PATH_MAX];                                          \
        const char* p = redirect(path, buf, sizeof(buf));            \
        return real(ver, p ? p : path, stat_buf);                    \
    }

WRAP_OPEN(open)
WRAP_OPEN(open64)
WRAP_FOPEN(fopen)
WRAP_FOPEN(fopen64)
WRAP_ACCESS(access)
WRAP_XSTAT(__xstat)
WRAP_XSTAT(__xstat64)
WRAP_XSTAT(__lxstat)
WRAP_XSTAT(__lxstat64)
