# Vitality Backend - 后端初始化完成

## 📦 已完成的内容

### 1. 数据库实体层 (Entity) ✅
完整的17个数据库表对应的JPA实体类：

**用户系统**
- `User` - 用户基础信息
- `UserBalance` - 用户余额（元气币、钥匙、金币）
- `BalanceTransaction` - 余额变动记录
- `UserStatistics` - 用户统计数据
- `UserSession` - 用户会话管理

**盲盒NFT系统**
- `BlindboxSeries` - 盲盒系列
- `CardDesign` - 卡片设计
- `CardInstance` - 卡片实例
- `UserCollection` - 用户收藏
- `BlindboxCardPool` - 盲盒卡池配置
- `DrawRecord` - 抽卡记录

**运动系统**
- `ExerciseRecord` - 运动记录
- `CheckinRecord` - 打卡记录

**交易系统**
- `P2pListing` - P2P挂单
- `P2pTransaction` - P2P交易记录

**系统配置**
- `SystemConfig` - 系统配置
- `UserActivityLog` - 用户行为日志

### 2. Repository层 ✅
所有实体对应的Spring Data JPA Repository接口，包含：
- 基础CRUD操作
- 自定义查询方法
- 分页查询支持
- 悲观锁支持（余额操作）

### 3. Service业务层 ✅
**UserService** - 用户服务
- 用户注册、登录
- 余额管理（元气币、钥匙增减）
- 用户信息查询
- 交易记录

**ExerciseService** - 运动服务
- 运动数据同步
- 卡路里转元气币
- 打卡功能
- 连续天数计算
- 统计数据更新

### 4. Controller API层 ✅
**UserController** - 用户接口
```
POST   /api/users/register          - 用户注册
POST   /api/users/login             - 用户登录
GET    /api/users/{userId}          - 获取用户信息
GET    /api/users/{userId}/balance  - 获取用户余额
GET    /api/users/{userId}/statistics - 获取用户统计
```

**ExerciseController** - 运动接口
```
POST   /api/exercise/sync          - 同步运动数据
POST   /api/exercise/convert       - 转换卡路里为元气币
POST   /api/exercise/checkin       - 打卡
GET    /api/exercise/records/{userId} - 获取运动记录
GET    /api/exercise/checkins/{userId} - 获取打卡记录
```

### 5. 基础设施 ✅
- `application.yml` - 完整的应用配置
- `ApiResponse<T>` - 统一响应格式
- `GlobalExceptionHandler` - 全局异常处理
- `BusinessException` - 业务异常
- `ResourceNotFoundException` - 资源未找到异常
- `IdGenerator` - ID生成工具

## 🚀 快速启动

### 1. 数据库准备
```bash
# 确保PostgreSQL已启动
brew services start postgresql

# 创建数据库和用户
cd VitalityBackend
./setup-database.sh
```

### 2. 启动应用
```bash
cd VitalityBackend
./mvnw clean install
./mvnw spring-boot:run
```

### 3. 测试API
```bash
# 用户注册
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123"
  }'

# 同步运动数据
curl -X POST http://localhost:8080/api/exercise/sync \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "返回的userId",
    "steps": 5000,
    "calories": 350,
    "date": "2026-01-04"
  }'

# 转换卡路里
curl -X POST http://localhost:8080/api/exercise/convert \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "返回的userId",
    "date": "2026-01-04"
  }'

# 打卡
curl -X POST http://localhost:8080/api/exercise/checkin \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "返回的userId"
  }'
```

## 📋 待实现功能

### 盲盒系统 (BlindboxService + Controller)
- [ ] 获取盲盒系列列表
- [ ] 购买盲盒
- [ ] 抽卡逻辑（概率算法）
- [ ] 保底机制
- [ ] NFT铸造
- [ ] 查看收藏

### P2P交易系统 (TradingService + Controller)
- [ ] 创建挂单
- [ ] 浏览市场
- [ ] 购买商品
- [ ] 取消挂单
- [ ] 交易手续费
- [ ] 所有权转移

### 市场数据接口
- [ ] 市场统计
- [ ] 热门商品
- [ ] 价格趋势
- [ ] 交易历史

## 🔐 安全性增强（推荐）

### 1. 添加Spring Security
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

### 2. 添加JWT认证
```xml
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.11.5</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
```

### 3. 密码加密
使用BCrypt加密密码：
```java
@Configuration
public class SecurityConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

## 📈 性能优化（推荐）

### 1. 添加Redis缓存
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

### 2. 配置连接池
在`application.yml`中已配置HikariCP

### 3. 添加参数验证
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

## 📖 API文档（推荐）

### 添加Swagger/OpenAPI
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

访问文档：http://localhost:8080/swagger-ui.html

## 🗂️ 项目结构
```
VitalityBackend/
├── src/main/java/com/vitality/
│   ├── entity/           # 实体类 ✅
│   │   ├── User.java
│   │   ├── UserBalance.java
│   │   ├── BlindboxSeries.java
│   │   └── ...
│   ├── repository/       # Repository接口 ✅
│   │   ├── UserRepository.java
│   │   ├── UserBalanceRepository.java
│   │   └── ...
│   ├── service/          # 业务服务 ✅
│   │   ├── UserService.java
│   │   ├── ExerciseService.java
│   │   └── ... (待扩展)
│   ├── controller/       # API控制器 ✅
│   │   ├── UserController.java
│   │   ├── ExerciseController.java
│   │   └── ... (待扩展)
│   ├── common/          # 公共类 ✅
│   │   └── ApiResponse.java
│   ├── exception/       # 异常处理 ✅
│   │   ├── BusinessException.java
│   │   ├── ResourceNotFoundException.java
│   │   └── GlobalExceptionHandler.java
│   └── util/            # 工具类 ✅
│       └── IdGenerator.java
├── src/main/resources/
│   └── application.yml  # 配置文件 ✅
└── pom.xml             # Maven配置 ✅
```

## 🎯 核心业务流程

### 1. 用户注册流程
```
用户注册 → 创建User → 初始化UserBalance → 初始化UserStatistics → 返回用户信息
```

### 2. 运动数据同步流程
```
前端同步数据 → 保存ExerciseRecord → 更新UserStatistics → 返回记录
```

### 3. 卡路里转换流程
```
请求转换 → 检查未转换卡路里 → 计算元气币 → 增加余额 → 记录交易 → 返回结果
```

### 4. 打卡流程
```
请求打卡 → 检查今日是否已打卡 → 验证目标完成 → 计算连续天数 → 保存打卡记录 → 更新统计
```

## 📝 数据库配置

确保在`application.yml`中正确配置数据库连接：
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/vitality_db
    username: vitality_user
    password: vitality_pass
```

## 🔍 常见问题

### 1. 数据库连接失败
- 检查PostgreSQL是否启动
- 检查数据库名、用户名、密码是否正确
- 运行`setup-database.sh`创建数据库

### 2. 端口冲突
修改`application.yml`中的端口：
```yaml
server:
  port: 8081  # 改为其他端口
```

### 3. Lombok不生效
确保IDE安装了Lombok插件，并启用了注解处理器

## 🎉 总结

后端核心架构已经初始化完成！包括：
- ✅ 完整的数据库实体层（17个表）
- ✅ Repository数据访问层
- ✅ 用户和运动系统的Service业务层
- ✅ 用户和运动系统的Controller API层
- ✅ 统一的响应格式和异常处理
- ✅ 基础配置和工具类

你现在可以：
1. 启动应用测试已有的API
2. 继续实现盲盒抽卡系统
3. 实现P2P交易系统
4. 添加安全认证
5. 优化性能和添加缓存

参考`BACKEND_INITIALIZATION_GUIDE.md`获取详细的实现示例代码！
