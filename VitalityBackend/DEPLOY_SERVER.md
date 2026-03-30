# Vitality Backend Server Deploy

这套部署文件专门给服务器使用，目标是:

- 不碰现有跑在 `wen-zi.com:80` 的旧项目
- 元气运动后端只占用 `8088`
- PostgreSQL 只在 Docker 内网访问，不对公网开放
- 先用 HTTP 联调，后面再单独补 HTTPS / 反向代理

## 文件

- `Dockerfile`
- `docker-compose.server.yml`
- `.env.server.example`

## 首次部署

1. 把整个 `VitalityBackend` 目录上传到服务器，例如:

```bash
scp -i /path/to/key.pem -r ./VitalityBackend ec2-user@wen-zi.com:/home/ec2-user/
```

2. 登录服务器并进入目录:

```bash
ssh -i /path/to/key.pem ec2-user@wen-zi.com
cd /home/ec2-user/VitalityBackend
```

3. 复制环境变量模板:

```bash
cp .env.server.example .env.server
```

4. 至少修改这几个值:

```env
POSTGRES_PASSWORD=your-strong-password
VITALITY_HTTP_PORT=8088
BASE_URL=http://wen-zi.com:8088
```

5. 启动:

```bash
docker compose --env-file .env.server -f docker-compose.server.yml up -d --build
```

## 查看状态

```bash
docker compose --env-file .env.server -f docker-compose.server.yml ps
docker compose --env-file .env.server -f docker-compose.server.yml logs -f vitality-backend
```

## 对外地址

部署完成后，接口地址是:

```text
http://wen-zi.com:8088/api
```

例如:

```bash
curl http://wen-zi.com:8088/api/blindbox/series/active
```

## 停止与更新

停止:

```bash
docker compose --env-file .env.server -f docker-compose.server.yml down
```

更新代码后重新构建:

```bash
docker compose --env-file .env.server -f docker-compose.server.yml up -d --build
```

## 说明

- 这套 compose 没有占用 `80` 或 `443`
- 数据库没有映射宿主机端口，避免碰现有项目，也更安全
- 当前项目里的部分盲盒图数据还是 `/images/...` 路径；这不影响后端先部署，但如果后面要让服务器直接提供这些图片，还需要补一层静态资源映射或对象存储方案
