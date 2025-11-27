# --- 构建阶段 (builder) ---
# 使用官方最新的 Golang 镜像作为构建基础
FROM golang:latest AS builder

# 设置工作目录
WORKDIR /app

# 安装 git，因为我们需要用它来克隆代码
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# 定义一个构建参数，用于指定要克隆的 Tailscale 分支
ARG TAILSCALE_BRANCH=main

# 使用 git clone 拉取指定分支的 Tailscale 代码库
RUN git clone -b v1.92.0 https://github.com/tailscale/tailscale.git /app/tailscale


# 编译 derper (你的原始编译命令保持不变)
RUN cd /app/tailscale/cmd/derper && \
    CGO_ENABLED=0 /usr/local/go/bin/go build -buildvcs=false -ldflags "-s -w" -o /app/derper && \
    cd /app && \
    rm -rf /app/tailscale

# --- 最终运行阶段 (使用轻量级 alpine 镜像) ---
# 使用 alpine:latest 作为最终的运行环境，体积非常小
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# Alpine 镜像使用 apk 包管理器
# 安装 ca-certificates，这通常是必需的，用于 HTTPS 证书验证
RUN apk add --no-cache ca-certificates && \
    mkdir /app/certs

# ===== 你的所有环境变量配置都完整保留在这里 =====
ENV DERP_DOMAIN=your-hostname.com
ENV DERP_CERT_MODE=letsencrypt
ENV DERP_CERT_DIR=/app/certs
ENV DERP_ADDR=:443
ENV DERP_STUN=true
ENV DERP_STUN_PORT=3478
ENV DERP_VERIFY_CLIENTS=false

# 从构建阶段复制编译好的 derper 二进制文件到最终镜像
COPY --from=builder /app/derper /app/derper

# ===== 你的容器启动命令也完整保留在这里 =====
CMD /app/derper \
   --hostname=$DERP_DOMAIN  \
   --certmode=$DERP_CERT_MODE \
   --certdir=$DERP_CERT_DIR \
   --a=$DERP_ADDR \
   --stun=$DERP_STUN  \
   --stun-port=$DERP_STUN_PORT \
   --http-port=-1 \
   --verify-clients=$DERP_VERIFY_CLIENTS