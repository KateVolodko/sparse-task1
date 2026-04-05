#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>

#define DEFAULT_BLOCK_SIZE 4096

void die(const char *msg) { perror(msg); exit(EXIT_FAILURE); }

int is_zero_block(const char *buf, size_t size) {
    for (size_t i = 0; i < size; i++) if (buf[i] != 0) return 0;
    return 1;
}

int main(int argc, char *argv[]) {
    int block_size = DEFAULT_BLOCK_SIZE, opt;
    while ((opt = getopt(argc, argv, "b:")) != -1) {
        if (opt == 'b') {
            block_size = atoi(optarg);
            if (block_size <= 0) { fprintf(stderr, "Invalid block size\n"); return EXIT_FAILURE; }
        } else { fprintf(stderr, "Usage: %s [-b block_size] <in> <out>\n", argv[0]); return EXIT_FAILURE; }
    }
    int remaining = argc - optind;
    char *input_path = NULL, *output_path = NULL;
    if (remaining == 1) output_path = argv[optind];
    else if (remaining == 2) { input_path = argv[optind]; output_path = argv[optind+1]; }
    else { fprintf(stderr, "Wrong number of arguments\n"); return EXIT_FAILURE; }

    int fd_in = input_path ? open(input_path, O_RDONLY) : STDIN_FILENO;
    if (fd_in < 0) die("open input");
    int fd_out = open(output_path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd_out < 0) die("open output");

    char *buf = malloc(block_size); if (!buf) die("malloc");
    ssize_t n; off_t total = 0;
    while ((n = read(fd_in, buf, block_size)) > 0) {
        if (n < block_size) memset(buf + n, 0, block_size - n);
        if (is_zero_block(buf, block_size)) { if (lseek(fd_out, n, SEEK_CUR) < 0) die("lseek"); total += n; }
        else { ssize_t w = write(fd_out, buf, n); if (w < 0) die("write"); total += w; }
    }
    if (n < 0) die("read");
    if (ftruncate(fd_out, total) < 0) die("ftruncate");
    if (input_path) close(fd_in);
    close(fd_out);
    free(buf);
    return EXIT_SUCCESS;
}
