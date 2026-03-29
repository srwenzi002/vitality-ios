#!/bin/bash
# Vitality Genesis 数据库启动脚本

set -e

echo "🚀 启动 Vitality Genesis 数据库..."

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo "❌ Docker未运行，请先启动Docker Desktop"
    exit 1
fi

# 启动数据库
echo "📦 启动PostgreSQL容器..."
docker-compose up -d postgres

# 等待数据库就绪
echo "⏳ 等待数据库启动..."
for i in {1..30}; do
    if docker exec vitality-postgres pg_isready -U vitality_admin -d vitality_genesis &> /dev/null; then
        echo "✅ 数据库已就绪！"
        break
    fi
    echo -n "."
    sleep 1
done

# 显示表数量
echo ""
echo "📊 数据库信息："
docker exec vitality-postgres psql -U vitality_admin -d vitality_genesis -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs echo "表数量:"

# 显示配置信息
echo ""
echo "======================================"
echo "✅ 数据库启动完成！"
echo "======================================"
echo "数据库: vitality_genesis"
echo "主机: localhost"
echo "端口: 5432"
echo "用户: vitality_admin"
echo "密码: VitalityPass2024!"
echo ""
echo "JDBC URL: jdbc:postgresql://localhost:5432/vitality_genesis"
echo ""
echo "命令行访问:"
echo "docker exec -it vitality-postgres psql -U vitality_admin -d vitality_genesis"
echo "======================================"
