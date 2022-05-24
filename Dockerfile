# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang git build-essential

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/libyuarel.git
WORKDIR /libyuarel
RUN git checkout mayhem

## Build
RUN make -j$(nproc) LIBFUZZER_INSTRUMENT=1 && make install && make fuzzer -j$(nproc)

# Package Stage
RUN mkdir /corpus
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /libyuarel/yuarel-fuzz /
COPY --from=builder /libyuarel/fuzz/corpus /corpus

## Set up fuzzing!
ENTRYPOINT []
CMD /yuarel-fuzz /corpus -close_fd_mask=2
