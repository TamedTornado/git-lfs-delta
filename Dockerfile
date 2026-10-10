FROM rust:1.99.0-bookworm@sha256:114c7a4425406451c2866b6aafe69fe29b1b298832db1277d411ac73c82d04d6 AS build
WORKDIR /source
COPY . .
RUN cargo build --locked --release -p git-lfs-delta-server
RUN mkdir -p /staging && chown 65532:65532 /staging

FROM gcr.io/distroless/cc-debian12:nonroot@sha256:66aa873a4a14fb164aa01296058efd8253744606d72715e45acface073359faa
COPY --from=build /source/target/release/git-lfs-delta-server /usr/local/bin/git-lfs-delta-server
COPY --from=build /source/target/release/git-lfs-delta-admin /usr/local/bin/git-lfs-delta-admin
COPY --from=build --chown=65532:65532 /staging /var/lib/git-lfs-delta/staging
EXPOSE 8080
ENV GIT_LFS_DELTA_BIND=0.0.0.0:8080
ENV GIT_LFS_DELTA_STAGING_DIR=/var/lib/git-lfs-delta/staging
VOLUME ["/var/lib/git-lfs-delta/staging"]
HEALTHCHECK --interval=15s --timeout=5s --retries=4 CMD ["/usr/local/bin/git-lfs-delta-admin", "healthcheck"]
ENTRYPOINT ["/usr/local/bin/git-lfs-delta-server"]
