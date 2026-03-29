#!/bin/bash
# API快速测试脚本

echo "🧪 Vitality API 测试脚本"
echo "========================"
echo ""

BASE_URL="http://localhost:8080/api"
USER_ID="admin"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试函数
test_api() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local data=$4
    
    echo -e "${YELLOW}测试: ${name}${NC}"
    echo "URL: ${method} ${url}"
    
    if [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "${url}" \
            -H "Content-Type: application/json" \
            -d "${data}" 2>&1)
    else
        response=$(curl -s -w "\n%{http_code}" "${url}" 2>&1)
    fi
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ 成功 (HTTP $http_code)${NC}"
        echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    else
        echo -e "${RED}❌ 失败 (HTTP $http_code)${NC}"
        echo "$body"
    fi
    echo ""
    echo "-----------------------------------"
    echo ""
}

# 检查后端是否运行
echo "🔍 检查后端状态..."
if curl -s "${BASE_URL}/users/${USER_ID}/balance" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 后端运行正常${NC}"
    echo ""
else
    echo -e "${RED}❌ 后端未运行或无法访问${NC}"
    echo "请确保后端已启动在 http://localhost:8080"
    exit 1
fi

# 执行测试
echo "开始API测试..."
echo ""

# 1. 获取用户余额
test_api "获取用户余额" "${BASE_URL}/users/${USER_ID}/balance"

# 2. 获取用户统计
test_api "获取用户统计" "${BASE_URL}/users/${USER_ID}/statistics"

# 3. 同步运动数据
today=$(date +%Y-%m-%d)
test_api "同步运动数据" "${BASE_URL}/exercise/sync" "POST" \
    "{\"userId\":\"${USER_ID}\",\"steps\":8000,\"calories\":350.5,\"date\":\"${today}\"}"

# 4. 转换卡路里为元气币
test_api "转换卡路里为元气币" "${BASE_URL}/exercise/convert" "POST" \
    "{\"userId\":\"${USER_ID}\",\"date\":\"${today}\"}"

# 5. 打卡
test_api "打卡" "${BASE_URL}/exercise/checkin" "POST" \
    "{\"userId\":\"${USER_ID}\"}"

# 6. 获取活动盲盒系列
test_api "获取活动盲盒系列" "${BASE_URL}/blindbox/series/active"

echo ""
echo "========================"
echo "✅ 测试完成！"
echo "========================"
