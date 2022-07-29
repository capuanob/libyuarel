# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang build-essential

## Add source code to the build stage.
WORKDIR /
ADD . libyuarel
WORKDIR /libyuarel

## Build
RUN make -j$(nproc) LIBFUZZER_INSTRUMENT=1 && make install LIBFUZZER_INSTRUMENT=1 && make fuzzer -j$(nproc)

# Package Stage
RUN mkdir /corpus
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /libyuarel/yuarel-fuzz /
COPY --from=builder /libyuarel/fuzz/corpus /corpus
COPY --from=builder /usr/lib/libyuarel.so.1 /usr/lib

## Set up fuzzing!
ENTRYPOINT []
CMD /yuarel-fuzz /corpus
