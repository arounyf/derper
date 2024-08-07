FROM golang:latest AS builder
WORKDIR /app

ADD tailscale /app/tailscale

# build modified derper
RUN cd /app/tailscale/cmd/derper && \
    CGO_ENABLED=0 /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper && \
    cd /app && \
    rm -rf /app/tailscale

FROM ubuntu
WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y ca-certificates && \
    mkdir /app/certs

ENV DERP_DOMAIN=your-hostname.com
ENV DERP_CERT_MODE=letsencrypt
ENV DERP_CERT_DIR=/app/certs
ENV DERP_ADDR=:443
ENV DERP_STUN=true
ENV DERP_STUN_PORT=3478
ENV DERP_HTTP_PORT=80
ENV DERP_VERIFY_CLIENTS=false

COPY --from=builder /app/derper /app/derper

CMD ["/app/derper"," --hostname=$DERP_DOMAIN --certmode=$DERP_CERT_MODE  --certdir=$DERP_CERT_DIR --a=$DERP_ADDR --stun=$DERP_STUN --stun-port=$DERP_STUN_PORT    --http-port=$DERP_HTTP_PORT --verify-clients=$DERP_VERIFY_CLIENTS"]

