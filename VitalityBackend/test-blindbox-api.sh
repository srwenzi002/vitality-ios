#!/bin/bash

# 盲盒抽奖接口测试脚本
# 测试完整链路：前端 → 后端 → 数据库

BASE_URL="http://localhost:8080/api"

echo "================================"
echo "盲盒抽奖接口测试"
echo "================================"
echo ""

# 1. 准备测试数据：创建测试用户
echo "1. 创建测试用户..."
USER_RESPONSE=$(curl -s -X POST "${BASE_URL}/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user_'$(date +%s)'",
    "email": "test'$(date +%s)'@example.com",
    "password": "Test123456",
    "phone": "13800138000"
  }')

echo "用户注册响应: $USER_RESPONSE"
USER_ID=$(echo $USER_RESPONSE | grep -o '"userId":"[^"]*"' | cut -d'"' -f4)
echo "用户ID: $USER_ID"
echo ""

# 2. 查询用户余额
echo "2. 查询用户余额..."
BALANCE_RESPONSE=$(curl -s -X GET "${BASE_URL}/users/${USER_ID}/balance")
echo "余额响应: $BALANCE_RESPONSE"
echo ""

# 3. 给用户添加密钥（用于抽奖）
echo "3. 准备测试数据：插入盲盒系列、卡片设计、卡池配置..."
echo "需要手动执行以下SQL（或者通过其他接口添加）："
echo ""
echo "-- 插入盲盒系列"
echo "INSERT INTO blindbox_series (series_code, series_name, description, release_date, "
echo "  payment_type, key_price, is_active, stock_quantity) "
echo "VALUES ('NEKO_S1', '猫猫战士第一季', '可爱的猫猫战士卡片', NOW(), 'key', 1, true, 100);"
echo ""
echo "-- 获取刚插入的 series_id"
echo "-- 假设 series_id = 1"
echo ""
echo "-- 插入卡片设计"
echo "INSERT INTO card_design (series_code, card_number, card_name, rarity, description, "
echo "  image_url, artist, release_date) VALUES"
echo "  ('NEKO_S1', 'C001', '猫猫战士N', 'N', 'N级猫猫战士', '/images/neko_n.png', 'Artist1', NOW()),"
echo "  ('NEKO_S1', 'C002', '猫猫战士R', 'R', 'R级猫猫战士', '/images/neko_r.png', 'Artist1', NOW()),"
echo "  ('NEKO_S1', 'C003', '猫猫战士SR', 'SR', 'SR级猫猫战士', '/images/neko_sr.png', 'Artist1', NOW()),"
echo "  ('NEKO_S1', 'C004', '猫猫战士SSR', 'SSR', 'SSR级猫猫战士', '/images/neko_ssr.png', 'Artist1', NOW());"
echo ""
echo "-- 获取卡片设计ID（假设分别为 1, 2, 3, 4）"
echo ""
echo "-- 插入卡池配置（概率）"
echo "INSERT INTO blindbox_card_pool (series_id, card_design_id, weight, guarantee_threshold) VALUES"
echo "  (1, 1, 50, NULL),  -- N级 50%"
echo "  (1, 2, 30, NULL),  -- R级 30%"
echo "  (1, 3, 15, NULL),  -- SR级 15%"
echo "  (1, 4, 5, 10);     -- SSR级 5%，10抽保底"
echo ""
echo "-- 给测试用户添加密钥"
echo "UPDATE user_balance SET key_balance = 10 WHERE user_id = '${USER_ID}';"
echo ""
echo "请先在数据库中执行上述SQL，然后按回车继续..."
read -p "数据准备完成？(y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "测试取消"
    exit 1
fi

# 4. 调用抽奖接口
echo "4. 调用抽奖接口..."
DRAW_RESPONSE=$(curl -s -X POST "${BASE_URL}/blindbox/draw" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "'${USER_ID}'",
    "seriesId": 1
  }')

echo "抽奖响应: $DRAW_RESPONSE"
echo ""

# 5. 再次查询用户余额（验证密钥是否扣除）
echo "5. 验证余额变化..."
BALANCE_AFTER=$(curl -s -X GET "${BASE_URL}/users/${USER_ID}/balance")
echo "抽奖后余额: $BALANCE_AFTER"
echo ""

# 6. 查询抽卡历史
echo "6. 查询抽卡历史..."
HISTORY_RESPONSE=$(curl -s -X GET "${BASE_URL}/blindbox/history/${USER_ID}")
echo "抽卡历史: $HISTORY_RESPONSE"
echo ""

# 7. 查询用户收藏（需要额外的接口，这里暂时跳过）
echo "7. 数据库验证..."
echo "请在数据库中执行以下查询验证数据："
echo ""
echo "-- 查看卡片实例"
echo "SELECT * FROM card_instance WHERE owner_user_id = '${USER_ID}';"
echo ""
echo "-- 查看用户收藏"
echo "SELECT * FROM user_collection WHERE user_id = '${USER_ID}';"
echo ""
echo "-- 查看抽卡记录"
echo "SELECT * FROM draw_record WHERE user_id = '${USER_ID}';"
echo ""
echo "-- 查看余额交易记录"
echo "SELECT * FROM balance_transaction WHERE user_id = '${USER_ID}' AND transaction_type = 'draw_blindbox';"
echo ""

echo "================================"
echo "测试完成"
echo "================================"
