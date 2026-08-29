FROM rust:1.98.0-bookworm@sha256:82150a52ec202c1b14d7817e14516c392bb7f5cfebd88f1ed531cb37ebd39922 AS build
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
