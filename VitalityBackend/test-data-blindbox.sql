-- 盲盒抽奖测试数据准备脚本
-- 执行这个脚本来准备测试数据

-- 1. 插入测试盲盒系列
INSERT INTO blindbox_series (series_code, series_name, description, release_date, payment_type, key_price, cash_price, is_active, stock_quantity)
VALUES 
  ('NEKO_S1', '猫猫战士第一季', '可爱的猫猫战士卡片系列', NOW(), 'key', 1, NULL, true, 100),
  ('NEKO_S2', '猫猫战士第二季', '全新的猫猫战士卡片', NOW(), 'cash', NULL, 9.99, true, 50);

-- 2. 插入卡片设计
INSERT INTO card_design (series_code, card_number, card_name, rarity, description, image_url, artist, release_date, supply_limit)
VALUES
  -- 第一季卡片
  ('NEKO_S1', 'C001', '猫猫战士N', 'N', 'N级猫猫战士，最基础的战士', '/images/neko_n.png', 'Artist_Neko', NOW(), NULL),
  ('NEKO_S1', 'C002', '猫猫战士R', 'R', 'R级猫猫战士，拥有初级技能', '/images/neko_r.png', 'Artist_Neko', NOW(), NULL),
  ('NEKO_S1', 'C003', '猫猫战士SR', 'SR', 'SR级猫猫战士，掌握中级技能', '/images/neko_sr.png', 'Artist_Neko', NOW(), 1000),
  ('NEKO_S1', 'C004', '猫猫战士SSR', 'SSR', 'SSR级猫猫战士，传说中的强者', '/images/neko_ssr.png', 'Artist_Neko', NOW(), 100),
  
  -- 第二季卡片
  ('NEKO_S2', 'C005', '黑猫刺客N', 'N', '黑猫刺客N级', '/images/black_cat_n.png', 'Artist_Black', NOW(), NULL),
  ('NEKO_S2', 'C006', '黑猫刺客R', 'R', '黑猫刺客R级', '/images/black_cat_r.png', 'Artist_Black', NOW(), NULL),
  ('NEKO_S2', 'C007', '黑猫刺客SR', 'SR', '黑猫刺客SR级', '/images/black_cat_sr.png', 'Artist_Black', NOW', 500),
  ('NEKO_S2', 'C008', '黑猫刺客SSR', 'SSR', '黑猫刺客SSR级', '/images/black_cat_ssr.png', 'Artist_Black', NOW(), 50);

-- 3. 获取系列ID和卡片设计ID（用于后续配置卡池）
-- 假设第一季 series_id = 1, 第二季 series_id = 2
-- 假设卡片设计ID依次为 1, 2, 3, 4, 5, 6, 7, 8

-- 4. 配置第一季卡池（权重模式：总权重100）
-- series_id = 1 (需要根据实际情况调整)
INSERT INTO blindbox_card_pool (series_id, card_design_id, weight, guarantee_threshold, is_active)
VALUES
  (1, 1, 50, NULL, true),   -- N级 50% 概率 (weight 50/100)
  (1, 2, 30, NULL, true),   -- R级 30% 概率 (weight 30/100)
  (1, 3, 15, NULL, true),   -- SR级 15% 概率 (weight 15/100)
  (1, 4, 5, 10, true);      -- SSR级 5% 概率，10抽保底 (weight 5/100)

-- 5. 配置第二季卡池
-- series_id = 2 (需要根据实际情况调整)
INSERT INTO blindbox_card_pool (series_id, card_design_id, weight, guarantee_threshold, is_active)
VALUES
  (2, 5, 45, NULL, true),   -- N级 45%
  (2, 6, 35, NULL, true),   -- R级 35%
  (2, 7, 15, NULL, true),   -- SR级 15%
  (2, 8, 5, 10, true);      -- SSR级 5%，10抽保底

-- 6. 创建测试用户（如果不存在）
-- 注意：这里的 user_id 格式需要符合你的生成规则
INSERT INTO "user" (user_id, username, email, password_hash, user_status, created_at)
VALUES 
  ('U1704441600000', 'test_user_1', 'test1@example.com', '$2a$10$encrypted_password', 'ACTIVE', NOW())
ON CONFLICT (user_id) DO NOTHING;

-- 7. 为测试用户初始化余额
INSERT INTO user_balance (user_id, vitality_coin_balance, key_balance, gold_coin_balance, frozen_vitality_coins, frozen_keys, frozen_gold_coins)
VALUES 
  ('U1704441600000', 1000, 20, 100.00, 0, 0, 0.00)
ON CONFLICT (user_id) DO UPDATE SET 
  key_balance = 20,
  gold_coin_balance = 100.00;

-- 8. 初始化用户统计
INSERT INTO user_statistics (user_id, total_steps, total_calories, total_vitality_coins_earned, total_checkin_days, consecutive_checkin_days)
VALUES 
  ('U1704441600000', 0, 0, 0, 0, 0)
ON CONFLICT (user_id) DO NOTHING;

-- 查询验证数据
SELECT '=== 盲盒系列 ===' as info;
SELECT series_id, series_code, series_name, payment_type, key_price, cash_price, is_active, stock_quantity 
FROM blindbox_series;

SELECT '=== 卡片设计 ===' as info;
SELECT card_design_id, series_code, card_number, card_name, rarity, supply_limit 
FROM card_design;

SELECT '=== 卡池配置 ===' as info;
SELECT bcp.pool_id, bcp.series_id, bs.series_name, bcp.card_design_id, cd.card_name, cd.rarity, bcp.weight, bcp.guarantee_threshold
FROM blindbox_card_pool bcp
JOIN blindbox_series bs ON bcp.series_id = bs.series_id
JOIN card_design cd ON bcp.card_design_id = cd.card_design_id
ORDER BY bcp.series_id, bcp.weight DESC;

SELECT '=== 测试用户 ===' as info;
SELECT u.user_id, u.username, u.email, ub.vitality_coin_balance, ub.key_balance, ub.gold_coin_balance
FROM "user" u
LEFT JOIN user_balance ub ON u.user_id = ub.user_id
WHERE u.username LIKE 'test_user%';
