-- 清理现有测试数据
DELETE FROM balance_transactions WHERE user_id = 'U1704441600000';
DELETE FROM draw_records WHERE user_id = 'U1704441600000';
DELETE FROM user_collections WHERE user_id = 'U1704441600000';
DELETE FROM card_instances WHERE card_design_id IN (SELECT id FROM card_designs WHERE blindbox_series_id IN (3, 4));
DELETE FROM blindbox_card_pools WHERE blindbox_series_id IN (3, 4);
DELETE FROM card_designs WHERE blindbox_series_id IN (3, 4);
DELETE FROM user_statistics WHERE user_id = 'U1704441600000';
DELETE FROM user_balances WHERE user_id = 'U1704441600000';
DELETE FROM users WHERE user_id = 'U1704441600000';
DELETE FROM blindbox_series WHERE series_code IN ('NEKO_S1', 'NEKO_S2');

-- 1. 插入盲盒系列（使用正确的小写值）
INSERT INTO blindbox_series (series_code, name, creator, description,
    price_type, price_keys, price_gold_coins, is_active, total_stock, sold_count)
VALUES 
    ('NEKO_S1', '猫猫战士第一季', '官方', '可爱的猫猫战士卡片系列',
     'keys_only', 1, 0.00, true, 100, 0),
    ('NEKO_S2', '黑猫刺客系列', '官方', '神秘的黑猫刺客卡片',
     'cash_only', 0, 9.99, true, 50, 0);

-- 获取刚插入的系列ID（使用变量）
DO $$
DECLARE
    series1_id INTEGER;
    series2_id INTEGER;
BEGIN
    -- 获取系列ID
    SELECT id INTO series1_id FROM blindbox_series WHERE series_code = 'NEKO_S1';
    SELECT id INTO series2_id FROM blindbox_series WHERE series_code = 'NEKO_S2';

    -- 2. 插入卡片设计（4张卡片给第一个系列）
    -- 注意：attributes使用jsonb存储游戏属性
    INSERT INTO card_designs (card_code, name, rarity, blindbox_series_id, 
        description, front_image_url, attributes, total_supply, asset_number_start, asset_number_end)
    VALUES 
        ('NEKO_N_001', '猫猫战士N', 'N', series1_id, '普通的猫猫战士', 
         'neko_warrior_n.png', '{"attack": 10, "defense": 10, "ability": "无"}'::jsonb, 
         1000, 1, 1000),
        ('NEKO_R_001', '猫猫战士R', 'R', series1_id, '稀有的猫猫战士',
         'neko_warrior_r.png', '{"attack": 20, "defense": 20, "ability": "小幅提升攻击"}'::jsonb,
         500, 1001, 1500),
        ('NEKO_SR_001', '猫猫战士SR', 'SR', series1_id, '超稀有的猫猫战士',
         'neko_warrior_sr.png', '{"attack": 35, "defense": 35, "ability": "大幅提升攻击"}'::jsonb,
         100, 1501, 1600),
        ('NEKO_SSR_001', '猫猫战士SSR', 'SSR', series1_id, '最稀有的猫猫战士',
         'neko_warrior_ssr.png', '{"attack": 50, "defense": 50, "ability": "极大提升全属性"}'::jsonb,
         50, 1601, 1650);

    -- 插入第二个系列的卡片（4张卡片）
    INSERT INTO card_designs (card_code, name, rarity, blindbox_series_id,
        description, front_image_url, attributes, total_supply, asset_number_start, asset_number_end)
    VALUES 
        ('BLACK_N_001', '黑猫刺客N', 'N', series2_id, '普通的黑猫刺客',
         'black_cat_n.png', '{"attack": 12, "defense": 8, "ability": "无"}'::jsonb,
         800, 2001, 2800),
        ('BLACK_R_001', '黑猫刺客R', 'R', series2_id, '稀有的黑猫刺客',
         'black_cat_r.png', '{"attack": 25, "defense": 15, "ability": "提升暴击率"}'::jsonb,
         400, 2801, 3200),
        ('BLACK_SR_001', '黑猫刺客SR', 'SR', series2_id, '超稀有的黑猫刺客',
         'black_cat_sr.png', '{"attack": 40, "defense": 25, "ability": "大幅提升暴击"}'::jsonb,
         80, 3201, 3280),
        ('BLACK_SSR_001', '黑猫刺客SSR', 'SSR', series2_id, '最稀有的黑猫刺客',
         'black_cat_ssr.png', '{"attack": 55, "defense": 40, "ability": "必定暴击"}'::jsonb,
         20, 3281, 3300);

    -- 3. 插入卡池配置（注意：pool_type使用小写）
    -- 第一个系列的卡池（通过card_code查找ID）
    INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type)
    SELECT series1_id, id, 
        CASE card_code
            WHEN 'NEKO_N_001' THEN 50
            WHEN 'NEKO_R_001' THEN 30
            WHEN 'NEKO_SR_001' THEN 15
            WHEN 'NEKO_SSR_001' THEN 5
        END,
        'normal'
    FROM card_designs 
    WHERE card_code IN ('NEKO_N_001', 'NEKO_R_001', 'NEKO_SR_001', 'NEKO_SSR_001');

    -- 第二个系列的卡池
    INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type)
    SELECT series2_id, id,
        CASE card_code
            WHEN 'BLACK_N_001' THEN 45
            WHEN 'BLACK_R_001' THEN 35
            WHEN 'BLACK_SR_001' THEN 15
            WHEN 'BLACK_SSR_001' THEN 5
        END,
        'normal'
    FROM card_designs
    WHERE card_code IN ('BLACK_N_001', 'BLACK_R_001', 'BLACK_SR_001', 'BLACK_SSR_001');

    -- 4. 插入测试用户
    INSERT INTO users (user_id, username, email, password_hash, status)
    VALUES ('U1704441600000', 'test_user_1', 'test1@example.com', 
            'hashed_password_placeholder', 'active');

    -- 5. 插入用户余额
    INSERT INTO user_balances (user_id, keys_count, gold_coins)
    VALUES ('U1704441600000', 20, 100.00);

    -- 6. 插入用户统计（使用正确的列名：total_vitality_coins_produced）
    INSERT INTO user_statistics (user_id, total_steps, total_calories, 
        total_vitality_coins_produced)
    VALUES ('U1704441600000', 0, 0, 0);

    RAISE NOTICE '数据插入完成！系列1 ID: %, 系列2 ID: %', series1_id, series2_id;
END $$;

-- 验证数据
SELECT '=== 盲盒系列 ===' as info;
SELECT id, series_code, name, price_type, price_keys, price_gold_coins, is_active, total_stock 
FROM blindbox_series 
WHERE series_code IN ('NEKO_S1', 'NEKO_S2');

SELECT '=== 卡片设计 ===' as info;
SELECT id, card_code, name, rarity, blindbox_series_id 
FROM card_designs 
WHERE blindbox_series_id IN (
    SELECT id FROM blindbox_series WHERE series_code IN ('NEKO_S1', 'NEKO_S2')
);

SELECT '=== 卡池配置 ===' as info;
SELECT id, blindbox_series_id, card_design_id, drop_weight, pool_type 
FROM blindbox_card_pools 
WHERE blindbox_series_id IN (
    SELECT id FROM blindbox_series WHERE series_code IN ('NEKO_S1', 'NEKO_S2')
);

SELECT '=== 测试用户 ===' as info;
SELECT u.user_id, u.username, ub.keys_count, ub.gold_coins 
FROM users u
JOIN user_balances ub ON u.user_id = ub.user_id
WHERE u.user_id = 'U1704441600000';
