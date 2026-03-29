#!/bin/bash
# 检查并初始化admin用户数据

echo "🔍 检查admin用户数据..."

# 检查用户是否存在
USER_EXISTS=$(docker exec vitality-postgres psql -U vitality_admin -d vitality_genesis -t -c "SELECT COUNT(*) FROM users WHERE user_id = 'admin';" 2>/dev/null | xargs)

if [ "$USER_EXISTS" = "0" ] || [ -z "$USER_EXISTS" ]; then
    echo "❌ admin用户不存在，正在创建..."
    
    docker exec vitality-postgres psql -U vitality_admin -d vitality_genesis <<EOSQL
-- 创建admin用户
INSERT INTO users (user_id, username, email, password_hash, status, created_at, updated_at)
VALUES ('admin', 'admin', 'admin@example.com', '\$2a\$10\$dummypasswordhash', 'ACTIVE', NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

-- 创建用户余额记录
INSERT INTO user_balances (user_id, vitality_coins, keys_count, gold_coins, frozen_vitality_coins, frozen_keys)
VALUES ('admin', 1000.0, 10, 100.0, 0.0, 0)
ON CONFLICT (user_id) DO UPDATE SET
    vitality_coins = 1000.0,
    keys_count = 10,
    gold_coins = 100.0;

-- 创建用户统计记录
INSERT INTO user_statistics (user_id, total_steps, total_calories, total_checkins, 
                            total_vitality_coins_produced, current_checkin_streak, 
                            max_checkin_streak, total_cards_obtained, total_draws_count)
VALUES ('admin', 0, 0.0, 0, 0.0, 0, 0, 0, 0)
ON CONFLICT (user_id) DO NOTHING;
EOSQL
    
    echo "✅ admin用户创建完成！"
else
    echo "✅ admin用户已存在"
fi

echo ""
echo "📊 当前admin用户数据："
echo "================================"

# 显示用户信息
echo "用户信息:"
docker exec vitality-postgres psql -U vitality_admin -d vitality_genesis -c "SELECT user_id, username, email, status FROM users WHERE user_id = 'admin';"

echo ""
echo "余额信息:"
docker exec vitality-postgres psql -U vitality_admin -d vitality_genesis -c "SELECT user_id, vitality_coins, keys_count, gold_coins FROM user_balances WHERE user_id = 'admin';"

echo ""
echo "统计信息:"
docker exec vitality-postgres psql -U vitality_admin -d vitality_genesis -c "SELECT user_id, total_steps, total_checkins, current_checkin_streak FROM user_statistics WHERE user_id = 'admin';"

echo ""
echo "================================"

