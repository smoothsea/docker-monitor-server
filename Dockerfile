#######################BUILD IMAGE##############
FROM rust:1.48.0 as build
ENV REFRESHED_AT 2021-06-28
RUN mkdir /app && cd /app && git clone https://github.com/smoothsea/monitor-server.git && cd monitor-server
WORKDIR /app/monitor-server
RUN rustup default nightly
RUN cargo build --release

#######################RUNTIME IMAGE##############
FROM debian:buster-slim
RUN apt-get update && apt-get install -y \
            --no-install-recommends \
            openssl \
            ca-certificates \
	    libsqlite3-0
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 
RUN mkdir /data
COPY --from=build app/monitor-server/target/release/monitor_server .
COPY --from=build app/monitor-server/templates ./templates/
WORKDIR /
CMD ["/monitor_server"]
