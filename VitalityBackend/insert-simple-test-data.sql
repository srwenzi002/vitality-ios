-- 简化版测试数据插入脚本
-- 直接匹配现有数据库表结构

-- 1. 插入盲盒系列
INSERT INTO blindbox_series (
    series_code, name, creator, description,
    price_type, price_keys, price_gold_coins,
    is_active, total_stock, sold_count
) VALUES 
    ('NEKO_S1', '猫猫战士第一季', '官方', '可爱的猫猫战士卡片系列',
     'keys_only', 1, 0.00,
     true, 100, 0),
    ('NEKO_S2', '黑猫刺客系列', '官方', '神秘的黑猫刺客卡片',
     'cash_only', 0, 9.99,
     true, 50, 0);

-- 2. 插入卡片设计
INSERT INTO card_designs (
    card_code, blindbox_series_id, name, rarity,
    front_image_url, total_supply, asset_number_start, asset_number_end,
    minted_count, is_active
) VALUES
    -- 第一季卡片 (假设 series_id = 1)
    ('NEKO_S1_C001', 1, '猫猫战士N', 'N', '/images/neko_n.png', 10000, 1, 10000, 0, true),
    ('NEKO_S1_C002', 1, '猫猫战士R', 'R', '/images/neko_r.png', 5000, 1, 5000, 0, true),
    ('NEKO_S1_C003', 1, '猫猫战士SR', 'SR', '/images/neko_sr.png', 1000, 1, 1000, 0, true),
    ('NEKO_S1_C004', 1, '猫猫战士SSR', 'SSR', '/images/neko_ssr.png', 100, 1, 100, 0, true),
    -- 第二季卡片 (假设 series_id = 2)
    ('NEKO_S2_C001', 2, '黑猫刺客N', 'N', '/images/black_n.png', 10000, 1, 10000, 0, true),
    ('NEKO_S2_C002', 2, '黑猫刺客R', 'R', '/images/black_r.png', 5000, 1, 5000, 0, true),
    ('NEKO_S2_C003', 2, '黑猫刺客SR', 'SR', '/images/black_sr.png', 500, 1, 500, 0, true),
    ('NEKO_S2_C004', 2, '黑猫刺客SSR', 'SSR', '/images/black_ssr.png', 50, 1, 50, 0, true);

-- 3. 配置卡池
INSERT INTO blindbox_card_pools (
    blindbox_series_id, card_design_id, drop_weight, pool_type, is_active
) VALUES
    -- 第一季卡池
    (1, 1, 50, 'NORMAL', true),  -- N级 50%
    (1, 2, 30, 'NORMAL', true),  -- R级 30%
    (1, 3, 15, 'NORMAL', true),  -- SR级 15%
    (1, 4, 5, 'GUARANTEED', true),  -- SSR级 5%
    -- 第二季卡池
    (2, 5, 45, 'NORMAL', true),
    (2, 6, 35, 'NORMAL', true),
    (2, 7, 15, 'NORMAL', true),
    (2, 8, 5, 'GUARANTEED', true);

-- 4. 创建测试用户
INSERT INTO users (
    user_id, username, email, phone,
    password_hash, status
) VALUES 
    ('U1704441600000', 'test_user_1', 'test1@example.com', '13800138000',
     '$2a$10$hash', 'active')
ON CONFLICT (user_id) DO NOTHING;

-- 5. 初始化用户余额
INSERT INTO user_balances (
    user_id, vitality_coins, keys_count, gold_coins
) VALUES 
    ('U1704441600000', 1000.00, 20, 100.00)
ON CONFLICT (user_id) 
DO UPDATE SET 
    keys_count = 20,
    gold_coins = 100.00;

-- 6. 初始化用户统计
INSERT INTO user_statistics (
    user_id, total_steps, total_calories, total_vitality_coins_earned,
    total_checkins, consecutive_checkins
) VALUES 
    ('U1704441600000', 0, 0.00, 0.00, 0, 0)
ON CONFLICT (user_id) DO NOTHING;

-- 验证数据
SELECT '数据插入完成！' as message;
SELECT * FROM blindbox_series;
SELECT id, card_code, name, rarity, blindbox_series_id FROM card_designs;
SELECT * FROM blindbox_card_pools;
SELECT u.user_id, u.username, ub.keys_count, ub.gold_coins 
FROM users u 
LEFT JOIN user_balances ub ON u.user_id = ub.user_id 
WHERE u.user_id = 'U1704441600000';
