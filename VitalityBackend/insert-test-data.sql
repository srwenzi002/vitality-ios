-- 盲盒抽奖测试数据准备脚本（修正版）
-- 匹配实际的数据库表结构

-- 清理旧数据（可选）
-- DELETE FROM balance_transactions WHERE user_id = 'U1704441600000';
-- DELETE FROM draw_records WHERE user_id = 'U1704441600000';
-- DELETE FROM user_collections WHERE user_id = 'U1704441600000';
-- DELETE FROM card_instances WHERE current_owner_id = 'U1704441600000';
-- DELETE FROM blindbox_card_pools;
-- DELETE FROM card_designs;
-- DELETE FROM blindbox_series;

-- 1. 插入测试盲盒系列
INSERT INTO blindbox_series (
    series_code, name, creator, description, 
    cover_image, cover_color, 
    price_type, price_keys, price_gold_coins, 
    is_active, total_stock, sold_count, 
    start_time, created_at, updated_at
) VALUES 
    ('NEKO_S1', '猫猫战士第一季', '官方', '可爱的猫猫战士卡片系列，包含N/R/SR/SSR四种稀有度', 
     '/images/neko_series_cover.png', '#FF6B6B', 
     'KEYS_ONLY', 1, 0.00, 
     true, 100, 0, 
     NOW(), NOW(), NOW()),
    ('NEKO_S2', '猫猫战士第二季', '官方', '全新的黑猫刺客卡片系列', 
     '/images/black_cat_series_cover.png', '#4ECDC4', 
     'CASH_ONLY', 0, 9.99, 
     true, 50, 0, 
     NOW(), NOW(), NOW());

-- 获取刚插入的系列ID（PostgreSQL）
DO $$
DECLARE
    series1_id INT;
    series2_id INT;
    card1_id BIGINT;
    card2_id BIGINT;
    card3_id BIGINT;
    card4_id BIGINT;
    card5_id BIGINT;
    card6_id BIGINT;
    card7_id BIGINT;
    card8_id BIGINT;
BEGIN
    -- 获取系列ID
    SELECT id INTO series1_id FROM blindbox_series WHERE series_code = 'NEKO_S1';
    SELECT id INTO series2_id FROM blindbox_series WHERE series_code = 'NEKO_S2';

    -- 2. 插入卡片设计（第一季）
    INSERT INTO card_designs (
        card_code, blindbox_series_id, name, rarity, 
        front_image_url, back_image_url, description, 
        total_supply, asset_number_start, asset_number_end, minted_count,
        is_tradable, is_active, created_at, updated_at
    ) VALUES
        ('NEKO_S1_C001', series1_id, '猫猫战士N', 'N', 
         '/images/neko_n.png', '/images/card_back.png', 'N级猫猫战士，最基础的战士', 
         10000, 1, 10000, 0, 
         true, true, NOW(), NOW()),
        ('NEKO_S1_C002', series1_id, '猫猫战士R', 'R', 
         '/images/neko_r.png', '/images/card_back.png', 'R级猫猫战士，拥有初级技能', 
         5000, 1, 5000, 0, 
         true, true, NOW(), NOW()),
        ('NEKO_S1_C003', series1_id, '猫猫战士SR', 'SR', 
         '/images/neko_sr.png', '/images/card_back.png', 'SR级猫猫战士，掌握中级技能', 
         1000, 1, 1000, 0, 
         true, true, NOW(), NOW()),
        ('NEKO_S1_C004', series1_id, '猫猫战士SSR', 'SSR', 
         '/images/neko_ssr.png', '/images/card_back.png', 'SSR级猫猫战士，传说中的强者', 
         100, 1, 100, 0, 
         true, true, NOW(), NOW());

    -- 获取第一季卡片ID
    SELECT id INTO card1_id FROM card_designs WHERE card_code = 'NEKO_S1_C001';
    SELECT id INTO card2_id FROM card_designs WHERE card_code = 'NEKO_S1_C002';
    SELECT id INTO card3_id FROM card_designs WHERE card_code = 'NEKO_S1_C003';
    SELECT id INTO card4_id FROM card_designs WHERE card_code = 'NEKO_S1_C004';

    -- 3. 配置第一季卡池
    INSERT INTO blindbox_card_pools (
        blindbox_series_id, card_design_id, 
        drop_weight, guaranteed_count, 
        pool_type, is_active, created_at, updated_at
    ) VALUES
        (series1_id, card1_id, 50, NULL, 'NORMAL', true, NOW(), NOW()),  -- N级 50%
        (series1_id, card2_id, 30, NULL, 'NORMAL', true, NOW(), NOW()),  -- R级 30%
        (series1_id, card3_id, 15, NULL, 'NORMAL', true, NOW(), NOW()),  -- SR级 15%
        (series1_id, card4_id, 5, 10, 'GUARANTEED', true, NOW(), NOW()); -- SSR级 5%，10抽保底

    -- 4. 插入卡片设计（第二季）
    INSERT INTO card_designs (
        card_code, blindbox_series_id, name, rarity, 
        front_image_url, back_image_url, description, 
        total_supply, asset_number_start, asset_number_end, minted_count,
        is_tradable, is_active, created_at, updated_at
    ) VALUES
        ('NEKO_S2_C001', series2_id, '黑猫刺客N', 'N', 
         '/images/black_cat_n.png', '/images/card_back.png', '黑猫刺客N级', 
         10000, 1, 10000, 0, 
         true, true, NOW(), NOW()),
        ('NEKO_S2_C002', series2_id, '黑猫刺客R', 'R', 
         '/images/black_cat_r.png', '/images/card_back.png', '黑猫刺客R级', 
         5000, 1, 5000, 0, 
         true, true, NOW(), NOW()),
        ('NEKO_S2_C003', series2_id, '黑猫刺客SR', 'SR', 
         '/images/black_cat_sr.png', '/images/card_back.png', '黑猫刺客SR级', 
         500, 1, 500, 0, 
         true, true, NOW(), NOW()),
        ('NEKO_S2_C004', series2_id, '黑猫刺客SSR', 'SSR', 
         '/images/black_cat_ssr.png', '/images/card_back.png', '黑猫刺客SSR级', 
         50, 1, 50, 0, 
         true, true, NOW(), NOW());

    -- 获取第二季卡片ID
    SELECT id INTO card5_id FROM card_designs WHERE card_code = 'NEKO_S2_C001';
    SELECT id INTO card6_id FROM card_designs WHERE card_code = 'NEKO_S2_C002';
    SELECT id INTO card7_id FROM card_designs WHERE card_code = 'NEKO_S2_C003';
    SELECT id INTO card8_id FROM card_designs WHERE card_code = 'NEKO_S2_C004';

    -- 5. 配置第二季卡池
    INSERT INTO blindbox_card_pools (
        blindbox_series_id, card_design_id, 
        drop_weight, guaranteed_count, 
        pool_type, is_active, created_at, updated_at
    ) VALUES
        (series2_id, card5_id, 45, NULL, 'NORMAL', true, NOW(), NOW()),  -- N级 45%
        (series2_id, card6_id, 35, NULL, 'NORMAL', true, NOW(), NOW()),  -- R级 35%
        (series2_id, card7_id, 15, NULL, 'NORMAL', true, NOW(), NOW()),  -- SR级 15%
        (series2_id, card8_id, 5, 10, 'GUARANTEED', true, NOW(), NOW()); -- SSR级 5%，10抽保底

    RAISE NOTICE '盲盒系列和卡片设计数据插入完成！';
    RAISE NOTICE '系列1 ID: %, 系列2 ID: %', series1_id, series2_id;
END $$;

-- 6. 创建测试用户
INSERT INTO users (
    user_id, username, email, phone, 
    password_hash, status, 
    registration_date, created_at, updated_at
) VALUES 
    ('U1704441600000', 'test_user_1', 'test1@example.com', '13800138000',
     '$2a$10$encrypted_password_hash_here', 'ACTIVE', 
     NOW(), NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

-- 7. 初始化用户余额
INSERT INTO user_balances (
    user_id, vitality_coins, keys_count, gold_coins, 
    frozen_vitality_coins, frozen_keys, 
    created_at, updated_at
) VALUES 
    ('U1704441600000', 1000.00, 20, 100.00, 
     0.00, 0, 
     NOW(), NOW())
ON CONFLICT (user_id) 
DO UPDATE SET 
    keys_count = 20,
    gold_coins = 100.00,
    updated_at = NOW();

-- 8. 初始化用户统计
INSERT INTO user_statistics (
    user_id, total_steps, total_calories_burned, 
    total_vitality_coins_earned, total_checkins, 
    consecutive_checkins, last_checkin_date,
    created_at, updated_at
) VALUES 
    ('U1704441600000', 0, 0.00, 
     0.00, 0, 
     0, NULL,
     NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;

-- 验证数据
SELECT '========================================' as separator;
SELECT '数据插入完成！以下是验证结果：' as message;
SELECT '========================================' as separator;

SELECT '=== 盲盒系列 ===' as info;
SELECT 
    id, series_code, name, 
    price_type, price_keys, price_gold_coins, 
    is_active, total_stock, sold_count 
FROM blindbox_series
ORDER BY id;

SELECT '=== 卡片设计 ===' as info;
SELECT 
    cd.id, cd.card_code, cd.name, cd.rarity, 
    bs.series_code, cd.total_supply, cd.minted_count 
FROM card_designs cd
JOIN blindbox_series bs ON cd.blindbox_series_id = bs.id
ORDER BY cd.id;

SELECT '=== 卡池配置 ===' as info;
SELECT 
    bcp.id, bs.name as series_name, 
    cd.name as card_name, cd.rarity, 
    bcp.drop_weight, bcp.pool_type
FROM blindbox_card_pools bcp
JOIN blindbox_series bs ON bcp.blindbox_series_id = bs.id
JOIN card_designs cd ON bcp.card_design_id = cd.id
ORDER BY bcp.blindbox_series_id, bcp.drop_weight DESC;

SELECT '=== 测试用户 ===' as info;
SELECT 
    u.user_id, u.username, u.email, u.status,
    ub.vitality_coins, ub.keys_count, ub.gold_coins
FROM users u
LEFT JOIN user_balances ub ON u.user_id = ub.user_id
WHERE u.user_id = 'U1704441600000';

SELECT '========================================' as separator;
SELECT '数据准备完成！可以开始测试抽奖功能了。' as message;
SELECT '使用 userId: U1704441600000, seriesId: 1 (第一季)' as tip;
SELECT '========================================' as separator;
