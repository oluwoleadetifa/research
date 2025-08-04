#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

const long NUM_VALUES = 6553000;
const int VALUE_SIZE = 16;  // 128 bits = 16 bytes
#define TOTAL_BYTES ((size_t)(NUM_VALUES * VALUE_SIZE))

double time_diff(struct timespec start, struct timespec end) {
    return (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
}

int main() {
    int fd = open("/dev/qrandom0", O_RDONLY);
    if (fd < 0) {
        perror("Failed to open /dev/qrandom0");
        return 1;
    }

    uint8_t *buffer = malloc(TOTAL_BYTES);
    if (!buffer) {
        perror("Failed to allocate memory");
        close(fd);
        return 1;
    }

    struct timespec start, end;
    ssize_t bytes_read = 0, result;

    printf("Reading %ld x 128-bit values (%zu bytes)...\n", NUM_VALUES, TOTAL_BYTES);
    clock_gettime(CLOCK_MONOTONIC, &start);

    while ((size_t)bytes_read < TOTAL_BYTES) {
        result = read(fd, buffer + bytes_read, TOTAL_BYTES - bytes_read);
        if (result < 0) {
            perror("Read error");
            free(buffer);
            close(fd);
            return 1;
        }
        bytes_read += result;
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    close(fd);

    double elapsed = time_diff(start, end);
    double mb_read = bytes_read / (1024.0 * 1024.0);
    double mbps = mb_read / elapsed;

    printf("Read complete.\n");
    printf("Time taken: %.3f seconds\n", elapsed);
    printf("Total bytes: %zd\n", bytes_read);
    printf("Throughput: %.2f MB/s\n", mbps);

    /*
    for (int i = 0; i < 5; i++) {
        uint64_t high, low;
        memcpy(&high, &buffer[i * VALUE_SIZE], 8);
        memcpy(&low,  &buffer[i * VALUE_SIZE + 8], 8);
        printf("Value %d: %016lx%016lx\n", i, high, low);
    }
    */

    free(buffer);
    return 0;
}
