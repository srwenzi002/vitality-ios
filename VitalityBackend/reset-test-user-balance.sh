#!/bin/bash

# 更新测试用户余额的便捷脚本
# 用户ID: U1704441600000

echo "🔄 更新测试用户余额..."
echo "用户ID: U1704441600000"
echo ""

# 执行SQL更新
docker exec -i vitality-postgres psql -U vitality_admin -d vitality_genesis << EOF

-- 更新测试用户余额
UPDATE user_balances 
SET 
    keys_count = 100000,
    gold_coins = 1000000.00,
    vitality_coins = 5000000.00,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 'U1704441600000';

-- 如果用户不存在则插入
INSERT INTO user_balances (user_id, keys_count, gold_coins, vitality_coins, frozen_keys, frozen_vitality_coins, created_at, updated_at)
SELECT 'U1704441600000', 100000, 1000000.00, 5000000.00, 0, 0.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM user_balances WHERE user_id = 'U1704441600000'
);

-- 显示更新后的余额
SELECT 
    user_id as "用户ID",
    keys_count as "钥匙数量",
    gold_coins as "金币",
    vitality_coins as "活力币",
    updated_at as "更新时间"
FROM user_balances 
WHERE user_id = 'U1704441600000';

EOF

echo ""
echo "✅ 测试用户余额更新完成！"
echo ""
echo "现在可以在应用中测试盲盒功能了。"
