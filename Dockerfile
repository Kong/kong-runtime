ARG OSTYPE=linux-gnu
ARG ARCHITECTURE=x86_64
ARG DOCKER_REGISTRY=ghcr.io
ARG DOCKER_IMAGE_NAME

# List out all image permutations to trick dependabot
FROM --platform=linux/amd64 ghcr.io/kong/kong-openssl:1.1.9-x86_64-linux-musl as x86_64-linux-musl
FROM --platform=linux/amd64 ghcr.io/kong/kong-openssl:1.1.9-x86_64-linux-gnu as x86_64-linux-gnu
FROM --platform=linux/arm64 ghcr.io/kong/kong-openssl:1.1.9-aarch64-linux-musl as aarch64-linux-musl
FROM --platform=linux/arm64 ghcr.io/kong/kong-openssl:1.1.9-aarch64-linux-gnu as aarch64-linux-gnu


# Run the build script
FROM $ARCHITECTURE-$OSTYPE as build

COPY . /tmp
WORKDIR /tmp

# Run our predecessor tests
# Configure, build, and install
# Run our own tests
# Re-run our predecessor tests
RUN /test/*/test.sh && \
    /tmp/build.sh && \
    /tmp/test.sh && \
    /test/*/test.sh

# Test scripts left where downstream images can run them
COPY test.sh /test/kong-runtime/test.sh
COPY .env /test/kong-runtime/.env

# Copy the build result to scratch so we can export the result
FROM scratch as package

COPY --from=build /tmp/build /
