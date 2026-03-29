# Vitality Sports — 本地开发启动指南

## 环境要求

| 工具 | 版本要求 | 说明 |
|------|----------|------|
| macOS | 13+ | iOS 开发必须 Mac |
| Xcode | 15+ | 运行 iOS 端 |
| Docker Desktop | 最新版 | 运行 PostgreSQL |
| Java | 17 | 运行后端 |

> Java 17 推荐通过 [Homebrew](https://brew.sh) 安装：`brew install openjdk@17`

---

## 目录结构

```
vitality_ios/
├── VitalityBackend/       # Spring Boot 后端
└── VitalitySportsIOS/     # iOS SwiftUI 前端
```

---

## 第一步：启动数据库（Docker）

进入后端目录，用 docker-compose 一键启动 PostgreSQL：

```bash
cd VitalityBackend
docker compose up -d
```

首次启动会自动执行 `docker/init/` 下的初始化脚本：
- `01-init.sql` — 建表、建索引
- `02-seed.sql` — 导入盲盒系列、卡片等初始数据

验证数据库是否正常：

```bash
docker ps | grep vitality-postgres
# 应看到 STATUS 为 Up
```

> 数据库信息：
> - Host: `127.0.0.1:5432`
> - Database: `vitality_genesis`
> - Username: `vitality_admin`
> - Password: `VitalityPass2024!`

---

## 第二步：启动后端（Spring Boot）

在 `VitalityBackend` 目录下，用 Maven Wrapper 启动（**无需安装 Maven**）：

```bash
cd VitalityBackend
./mvnw spring-boot:run
```

Windows 用户使用：

```bat
mvnw.cmd spring-boot:run
```

首次启动会自动下载依赖，需要几分钟。启动成功后看到：

```
Tomcat started on port 8080
```

后端地址：`http://localhost:8080/api`

### 验证后端正常

```bash
curl http://localhost:8080/api/blindbox/series
# 应返回 JSON 数组，包含盲盒系列数据
```

### 上传目录（静态图片）

后端会将用户上传的图片存放在 `VitalityBackend/uploads/` 目录下（自动创建）。
内置的盲盒图片已随后端静态资源一起打包，位于 `src/main/resources/static/images/`，无需额外操作。

---

## 第三步：运行 iOS 端

1. 用 Xcode 打开 `VitalitySportsIOS/VitalitySports.xcodeproj`
2. 选择模拟器或真机（iPhone，iOS 17+）
3. 点击运行（⌘R）

> **注意**：iOS 模拟器连接的是本机 `127.0.0.1`，与后端地址一致，无需额外配置。
> 真机调试时需要将后端地址改为局域网 IP（见下方"真机调试"章节）。

---

## 真机调试（可选）

如果需要在真实设备上运行：

1. 确认手机和电脑在同一 Wi-Fi
2. 查询电脑局域网 IP：
   ```bash
   ipconfig getifaddr en0
   # 例如：192.168.1.100
   ```
3. 修改 `VitalitySportsIOS/VitalitySports/NetworkService.swift` 中的 `baseURL`，将 `127.0.0.1` 替换为上述 IP

---

## 常用命令

### 停止数据库

```bash
cd VitalityBackend
docker compose down
```

### 重置数据库（清空所有数据重新初始化）

```bash
cd VitalityBackend
docker compose down -v       # -v 会删除数据卷
docker compose up -d
```

### 查看后端日志

后端直接在终端输出，`Ctrl+C` 停止。

### 查看数据库内容

```bash
docker exec -it vitality-postgres psql -U vitality_admin -d vitality_genesis
```

常用 SQL：

```sql
\dt                          -- 列出所有表
SELECT * FROM blind_box_series;
SELECT * FROM collectible_cards LIMIT 10;
\q                           -- 退出
```

---

## 常见问题

**Q: `./mvnw` 提示 Permission denied**

```bash
chmod +x ./mvnw
```

**Q: 后端启动报 `Connection refused`（数据库连不上）**

确认 Docker 已启动且容器正在运行：

```bash
docker ps | grep vitality-postgres
```

如果容器不在，重新执行 `docker compose up -d`。

**Q: Xcode 报网络请求失败**

确认后端已启动（终端有 `Tomcat started on port 8080` 输出），然后重新运行 App。

**Q: 模拟器图片不显示**

图片由后端 `http://localhost:8080/api` 提供，确认后端正在运行即可。
