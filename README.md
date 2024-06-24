# Derper

[![docker workflow](https://github.com/fredliang44/derper-docker/actions/workflows/docker-image.yml/badge.svg)](https://hub.docker.com/r/runyf/derper)
[![docker pulls](https://img.shields.io/docker/pulls/runyf/derper.svg?color=brightgreen)](https://hub.docker.com/r/runyf/derper)
[![platfrom](https://img.shields.io/badge/platform-amd64%20%7C%20arm64-brightgreen)](https://hub.docker.com/r/runyf/derper/tags)

# 配置

> 设置 `DERP_DOMAIN` 参数为你的域名

```bash
docker run -e DERP_DOMAIN=derper.your-domain.com -p 80:80 -p 443:443 -p 3478:3478/udp runyf/derper
```

| 参数                |   必须   | 描述                                                                   |        默认值      |
| ------------------- | -------- | ---------------------------------------------------------------------- | ----------------- |
| DERP_DOMAIN         | true     | 域名                                                                   | your-hostname.com |
| DERP_CERT_DIR       | false    | 证书保存目录                                                            | /app/certs        |
| DERP_CERT_MODE      | false    | 证书模式. 可选: manual, letsencrypt                                     | letsencrypt       |
| DERP_ADDR           | false    | 服务监听端口                                                            | :443              |
| DERP_STUN           | false    | 仅运行STUN服务                                                          | true              |
| DERP_STUN_PORT      | false    | STUN服务UDP端口号                                                       | 3478              |
| DERP_HTTP_PORT      | false    | DERP HTTP端口. 设置-1为禁用                                             | 80                |
| DERP_VERIFY_CLIENTS | false    | DERP客户端证书验证(防白嫖)                                               | false             |

# 用法

完整的DERP官方文档请查看: https://tailscale.com/kb/1118/custom-derp-servers/

## 客户端验证

如果使用了 `DERP_VERIFY_CLIENTS`, 容器需要访问 Tailscale 本地 API, 通过访问此sock文件 `/var/run/tailscale/tailscaled.sock`. 如果你运行了 Tailscale 服务, 需要给 `docker run` 命令添加此参数 `-v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock`
