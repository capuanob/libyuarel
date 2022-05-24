#include <stdint.h> // uint8_t
#include <string.h> // memcpy
#include <yuarel.h>

int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
    size_t i;
    char* url_str;
    char *parts[3];
    struct yuarel url;
    struct yuarel_param params[3];

    // Create a non-const duplicate of the input data that is null-terminated
    char buff[size];
    memcpy(buff, data, size);
    buff[size - 1] = '\0';

    while (i < size) {
        url_str = buff + i;

        if (yuarel_parse(&url, url_str) != -1) {
            // Continue fuzzing
            if (yuarel_split_path(url.path, parts, 3) == 3) {
                yuarel_parse_query(url.query, '&', params, 3);
            }
        }
        i += 1 + strlen(url_str);
    }
    return 0;
}
