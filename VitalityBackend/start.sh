#!/bin/bash
# 启动Spring Boot后端

echo "🚀 启动 Vitality Backend..."

# 检查数据库是否运行
if ! docker ps | grep -q vitality-postgres; then
    echo "⚠️  数据库未运行，正在启动..."
    ./setup-database.sh
fi

echo ""
echo "📦 启动Spring Boot应用..."
echo "访问地址: http://localhost:8080/api"
echo ""

# 使用Maven Wrapper启动
./mvnw spring-boot:run
