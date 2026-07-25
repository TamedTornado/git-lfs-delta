FROM rust:1.97.1-bookworm@sha256:77fac8b98f9f46062bb680b6d25d5bcaabfc400143952ebc572e924bcbedc3fa AS build
WORKDIR /source
COPY . .
RUN cargo build --locked --release -p git-lfs-delta-server
RUN mkdir -p /staging && chown 65532:65532 /staging

FROM gcr.io/distroless/cc-debian12:nonroot@sha256:fccdbb0a547c14e23fcf4ce8ad62ca5d43b4faae8d22cd292f490fef9946c96e
COPY --from=build /source/target/release/git-lfs-delta-server /usr/local/bin/git-lfs-delta-server
COPY --from=build /source/target/release/git-lfs-delta-admin /usr/local/bin/git-lfs-delta-admin
COPY --from=build --chown=65532:65532 /staging /var/lib/git-lfs-delta/staging
EXPOSE 8080
ENV GIT_LFS_DELTA_BIND=0.0.0.0:8080
ENV GIT_LFS_DELTA_STAGING_DIR=/var/lib/git-lfs-delta/staging
VOLUME ["/var/lib/git-lfs-delta/staging"]
HEALTHCHECK --interval=15s --timeout=5s --retries=4 CMD ["/usr/local/bin/git-lfs-delta-admin", "healthcheck"]
ENTRYPOINT ["/usr/local/bin/git-lfs-delta-server"]
