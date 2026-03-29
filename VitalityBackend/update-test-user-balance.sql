-- 更新测试用户余额
-- 用户ID: U1704441600000

-- 检查用户余额是否存在
SELECT user_id, keys_count, gold_coins, vitality_coins 
FROM user_balances 
WHERE user_id = 'U1704441600000';

-- 如果存在，则更新
UPDATE user_balances 
SET 
    keys_count = 100000,
    gold_coins = 1000000.00,
    vitality_coins = 5000000.00,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 'U1704441600000';

-- 如果不存在，则插入
INSERT INTO user_balances (user_id, keys_count, gold_coins, vitality_coins, frozen_keys, frozen_vitality_coins, created_at, updated_at)
SELECT 'U1704441600000', 100000, 1000000.00, 5000000.00, 0, 0.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM user_balances WHERE user_id = 'U1704441600000'
);

-- 验证更新结果
SELECT user_id, keys_count, gold_coins, vitality_coins 
FROM user_balances 
WHERE user_id = 'U1704441600000';
