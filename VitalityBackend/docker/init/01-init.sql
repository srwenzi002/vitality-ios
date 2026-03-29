-- Vitality Genesis Database Schema
-- PostgreSQL 16+
-- Created: 2025-12-23

-- 创建数据库扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 用户系统
-- ========================================

-- 1. 用户表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    avatar_url VARCHAR(500),
    profile_bio TEXT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);

COMMENT ON TABLE users IS '用户基础信息表';
COMMENT ON COLUMN users.user_id IS '用户唯一标识';
COMMENT ON COLUMN users.status IS '账户状态: active, suspended, deleted';

-- 2. 用户余额表
CREATE TABLE user_balances (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    vitality_coins DECIMAL(15,2) DEFAULT 0,
    keys_count INTEGER DEFAULT 0,
    gold_coins DECIMAL(15,2) DEFAULT 0,
    frozen_vitality_coins DECIMAL(15,2) DEFAULT 0,
    frozen_keys INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_balance UNIQUE (user_id)
);

CREATE INDEX idx_user_balances_user_id ON user_balances(user_id);
CREATE INDEX idx_user_balances_vitality_coins ON user_balances(vitality_coins);
CREATE INDEX idx_user_balances_keys_count ON user_balances(keys_count);

COMMENT ON TABLE user_balances IS '用户余额表';
COMMENT ON COLUMN user_balances.vitality_coins IS '元气币余额';
COMMENT ON COLUMN user_balances.keys_count IS '钥匙库存';
COMMENT ON COLUMN user_balances.frozen_vitality_coins IS '冻结的元气币';

-- 3. 余额变动记录表
CREATE TABLE balance_transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    currency_type VARCHAR(20) NOT NULL CHECK (currency_type IN ('vitality_coins', 'keys', 'gold_coins')),
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('draw', 'convert', 'trade', 'transfer')),
    amount DECIMAL(15,2) NOT NULL,
    balance_before DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_balance_transactions_user_transaction ON balance_transactions(user_id, created_at);
CREATE INDEX idx_balance_transactions_transaction_id ON balance_transactions(transaction_id);
CREATE INDEX idx_balance_transactions_currency_type ON balance_transactions(currency_type);
CREATE INDEX idx_balance_transactions_transaction_type ON balance_transactions(transaction_type);

COMMENT ON TABLE balance_transactions IS '余额变动记录表';
COMMENT ON COLUMN balance_transactions.amount IS '变动金额(正为收入，负为支出)';

-- ========================================
-- NFT 和盲盒系统
-- ========================================

-- 4. 盲盒系列表
CREATE TABLE blindbox_series (
    id SERIAL PRIMARY KEY,
    series_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    creator VARCHAR(100) NOT NULL,
    description TEXT,
    cover_image VARCHAR(500),
    cover_color VARCHAR(50),
    price_type VARCHAR(20) DEFAULT 'keys_only' CHECK (price_type IN ('keys_only', 'keys_and_cash', 'cash_only')),
    price_keys INTEGER NOT NULL,
    price_gold_coins DECIMAL(10,2) DEFAULT 0,
    total_cards INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    total_stock INTEGER,
    sold_count INTEGER DEFAULT 0,
    max_per_user INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_blindbox_series_series_code ON blindbox_series(series_code);
CREATE INDEX idx_blindbox_series_creator ON blindbox_series(creator);
CREATE INDEX idx_blindbox_series_active_time ON blindbox_series(is_active, start_time, end_time);
CREATE INDEX idx_blindbox_series_price_type ON blindbox_series(price_type);
CREATE INDEX idx_blindbox_series_created_at ON blindbox_series(created_at);

COMMENT ON TABLE blindbox_series IS '盲盒系列表';
COMMENT ON COLUMN blindbox_series.price_type IS '价格类型: keys_only, keys_and_cash, cash_only';
COMMENT ON COLUMN blindbox_series.total_stock IS '总库存(-1表示无限)';

-- 5. 卡片设计表
CREATE TABLE card_designs (
    id BIGSERIAL PRIMARY KEY,
    card_code VARCHAR(50) UNIQUE NOT NULL,
    blindbox_series_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    rarity VARCHAR(10) NOT NULL CHECK (rarity IN ('n', 'r', 'sr', 'ssr')),
    front_image_url VARCHAR(500),
    back_image_url VARCHAR(500),
    description TEXT,
    attributes JSONB,
    total_supply INTEGER NOT NULL,
    asset_number_start INTEGER NOT NULL,
    asset_number_end INTEGER NOT NULL,
    minted_count INTEGER DEFAULT 0,
    is_tradable BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blindbox_series_id) REFERENCES blindbox_series(id)
);

CREATE INDEX idx_card_designs_card_code ON card_designs(card_code);
CREATE INDEX idx_card_designs_series ON card_designs(blindbox_series_id);
CREATE INDEX idx_card_designs_series_rarity ON card_designs(blindbox_series_id, rarity);
CREATE INDEX idx_card_designs_rarity ON card_designs(rarity);
CREATE INDEX idx_card_designs_asset_range ON card_designs(asset_number_start, asset_number_end);
CREATE INDEX idx_card_designs_is_active ON card_designs(is_active);

COMMENT ON TABLE card_designs IS '卡片设计表(定义卡片类型，一个设计对应多个编号实例)';
COMMENT ON COLUMN card_designs.attributes IS '卡片属性(JSON格式)';
COMMENT ON COLUMN card_designs.is_tradable IS '是否可交易（免费盲盒的卡片不可交易）';

-- 6. 卡片实例表
CREATE TABLE card_instances (
    id BIGSERIAL PRIMARY KEY,
    card_design_id BIGINT NOT NULL,
    asset_number INTEGER NOT NULL,
    instance_status VARCHAR(20) DEFAULT 'unminted' CHECK (instance_status IN ('unminted', 'minted', 'burned')),
    mint_transaction_id VARCHAR(50),
    minted_at TIMESTAMP,
    current_owner_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_design_asset UNIQUE (card_design_id, asset_number),
    FOREIGN KEY (card_design_id) REFERENCES card_designs(id)
);

CREATE INDEX idx_card_instances_card_design ON card_instances(card_design_id);
CREATE INDEX idx_card_instances_owner ON card_instances(current_owner_id, instance_status);
CREATE INDEX idx_card_instances_asset_number ON card_instances(asset_number);
CREATE INDEX idx_card_instances_status ON card_instances(instance_status);
CREATE INDEX idx_card_instances_mint_status ON card_instances(instance_status, minted_at);

COMMENT ON TABLE card_instances IS '卡片实例表(具体的卡片实例，每张卡有唯一资产编号)';
COMMENT ON COLUMN card_instances.instance_status IS '实例状态: unminted, minted, burned';

-- 7. 用户收藏表
CREATE TABLE user_collections (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    card_instance_id BIGINT NOT NULL,
    obtained_method VARCHAR(20) NOT NULL CHECK (obtained_method IN ('blindbox', 'trading', 'reward', 'airdrop')),
    obtained_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_id VARCHAR(50),
    is_locked BOOLEAN DEFAULT FALSE,
    lock_reason VARCHAR(100),
    lock_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_instance UNIQUE (user_id, card_instance_id),
    FOREIGN KEY (card_instance_id) REFERENCES card_instances(id)
);

CREATE INDEX idx_user_collections_user_id ON user_collections(user_id);
CREATE INDEX idx_user_collections_user_obtained ON user_collections(user_id, obtained_date);
CREATE INDEX idx_user_collections_card_instance ON user_collections(card_instance_id);
CREATE INDEX idx_user_collections_obtained_method ON user_collections(obtained_method);
CREATE INDEX idx_user_collections_is_locked ON user_collections(is_locked);

COMMENT ON TABLE user_collections IS '用户收藏表(用户拥有的具体卡片实例)';
COMMENT ON COLUMN user_collections.obtained_method IS '获得方式: blindbox, trading, reward, airdrop';

-- 8. 盲盒卡池配置表
CREATE TABLE blindbox_card_pools (
    id BIGSERIAL PRIMARY KEY,
    blindbox_series_id INTEGER NOT NULL,
    card_design_id BIGINT NOT NULL,
    drop_weight INTEGER DEFAULT 1,
    guaranteed_count INTEGER,
    max_drops_per_day INTEGER,
    current_daily_drops INTEGER DEFAULT 0,
    pool_type VARCHAR(20) DEFAULT 'normal' CHECK (pool_type IN ('normal', 'guaranteed', 'special', 'limited')),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_series_card_pool UNIQUE (blindbox_series_id, card_design_id, pool_type),
    FOREIGN KEY (blindbox_series_id) REFERENCES blindbox_series(id),
    FOREIGN KEY (card_design_id) REFERENCES card_designs(id)
);

CREATE INDEX idx_blindbox_card_pools_series ON blindbox_card_pools(blindbox_series_id);
CREATE INDEX idx_blindbox_card_pools_blindbox_card ON blindbox_card_pools(blindbox_series_id, card_design_id);
CREATE INDEX idx_blindbox_card_pools_card_design ON blindbox_card_pools(card_design_id);
CREATE INDEX idx_blindbox_card_pools_drop_weight ON blindbox_card_pools(drop_weight);
CREATE INDEX idx_blindbox_card_pools_pool_type ON blindbox_card_pools(pool_type, is_active);
CREATE INDEX idx_blindbox_card_pools_time_range ON blindbox_card_pools(start_time, end_time);
CREATE INDEX idx_blindbox_card_pools_is_active ON blindbox_card_pools(is_active);

COMMENT ON TABLE blindbox_card_pools IS '盲盒卡池配置表(配置具体卡片的掉落概率和限制)';
COMMENT ON COLUMN blindbox_card_pools.drop_weight IS '掉落权重(在同级别下的掉落权重)';

-- 9. 抽卡记录表
CREATE TABLE draw_records (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    blindbox_series_id INTEGER NOT NULL,
    draw_type VARCHAR(20) NOT NULL CHECK (draw_type IN ('single', 'three', 'five', 'ten')),
    keys_consumed INTEGER DEFAULT 0,
    price_gold_coins_consumed DECIMAL(10,2) DEFAULT 0,
    cards_obtained JSONB NOT NULL,
    total_cards INTEGER NOT NULL,
    rarity_breakdown JSONB,
    card_instances_created JSONB,
    is_guaranteed_triggered BOOLEAN DEFAULT FALSE,
    guaranteed_card_instance_id BIGINT,
    draw_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    FOREIGN KEY (blindbox_series_id) REFERENCES blindbox_series(id)
);

CREATE INDEX idx_draw_records_user_draw ON draw_records(user_id, draw_time);
CREATE INDEX idx_draw_records_series_draw ON draw_records(blindbox_series_id, draw_time);
CREATE INDEX idx_draw_records_series ON draw_records(blindbox_series_id);
CREATE INDEX idx_draw_records_draw_type ON draw_records(draw_type);
CREATE INDEX idx_draw_records_guaranteed ON draw_records(is_guaranteed_triggered, guaranteed_card_instance_id);
CREATE INDEX idx_draw_records_transaction_id ON draw_records(transaction_id);
CREATE INDEX idx_draw_records_draw_time ON draw_records(draw_time);

COMMENT ON TABLE draw_records IS '抽卡记录表(记录具体获得的卡片实例)';
COMMENT ON COLUMN draw_records.cards_obtained IS 'JSON格式的获得卡片实例列表';

-- ========================================
-- 运动系统
-- ========================================

-- 10. 运动记录表
CREATE TABLE exercise_records (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    record_date DATE NOT NULL,
    steps_count INTEGER DEFAULT 0,
    calories_burned DECIMAL(8,2) DEFAULT 0,
    vitality_coins_converted DECIMAL(10,2) DEFAULT 0,
    conversion_rate DECIMAL(8,4) DEFAULT 1.0000,
    sync_source VARCHAR(20) DEFAULT 'manual' CHECK (sync_source IN ('ios_health', 'android_fit', 'fitbit', 'garmin', 'manual', 'other')),
    raw_device_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_date UNIQUE (user_id, record_date)
);

CREATE INDEX idx_exercise_records_user_id ON exercise_records(user_id);
CREATE INDEX idx_exercise_records_user_records ON exercise_records(user_id, record_date);
CREATE INDEX idx_exercise_records_record_date ON exercise_records(record_date);
CREATE INDEX idx_exercise_records_sync_source ON exercise_records(sync_source);
CREATE INDEX idx_exercise_records_created_at ON exercise_records(created_at);

COMMENT ON TABLE exercise_records IS '运动记录表';
COMMENT ON COLUMN exercise_records.conversion_rate IS '当时卡路里→活力币转换率';

-- 11. 打卡记录表
CREATE TABLE checkin_records (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    checkin_date DATE NOT NULL,
    checkin_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    goal_achievement_verified BOOLEAN DEFAULT FALSE,
    consecutive_days INTEGER DEFAULT 1,
    max_streak_days INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_checkin_date UNIQUE (user_id, checkin_date)
);

CREATE INDEX idx_checkin_records_user_id ON checkin_records(user_id);
CREATE INDEX idx_checkin_records_user_checkin ON checkin_records(user_id, checkin_date);
CREATE INDEX idx_checkin_records_checkin_date ON checkin_records(checkin_date);
CREATE INDEX idx_checkin_records_consecutive_days ON checkin_records(consecutive_days);
CREATE INDEX idx_checkin_records_goal_verified ON checkin_records(goal_achievement_verified);

COMMENT ON TABLE checkin_records IS '打卡记录表(基于运动目标达成)';
COMMENT ON COLUMN checkin_records.consecutive_days IS '当前连续打卡天数';

-- 12. 用户统计表
CREATE TABLE user_statistics (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    total_steps BIGINT DEFAULT 0,
    total_calories DECIMAL(12,2) DEFAULT 0,
    total_checkins INTEGER DEFAULT 0,
    total_vitality_coins_produced DECIMAL(15,2) DEFAULT 0,
    current_checkin_streak INTEGER DEFAULT 0,
    max_checkin_streak INTEGER DEFAULT 0,
    total_cards_obtained INTEGER DEFAULT 0,
    total_draws_count INTEGER DEFAULT 0,
    total_gold_spent DECIMAL(12,2) DEFAULT 0,
    last_exercise_date DATE,
    last_checkin_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_statistics UNIQUE (user_id)
);

CREATE INDEX idx_user_statistics_user_id ON user_statistics(user_id);
CREATE INDEX idx_user_statistics_activity ON user_statistics(last_exercise_date, last_checkin_date);
CREATE INDEX idx_user_statistics_streaks ON user_statistics(current_checkin_streak, max_checkin_streak);
CREATE INDEX idx_user_statistics_total_vitality ON user_statistics(total_vitality_coins_produced);

COMMENT ON TABLE user_statistics IS '用户统计表';
COMMENT ON COLUMN user_statistics.total_vitality_coins_produced IS '累计产生的活力币总量';

-- ========================================
-- P2P交易系统
-- ========================================

-- 13. 交易挂单表
CREATE TABLE p2p_listings (
    id BIGSERIAL PRIMARY KEY,
    listing_id VARCHAR(50) UNIQUE NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('keys', 'card_instance', 'blindbox')),
    card_instance_id BIGINT,
    keys_quantity INTEGER,
    blindbox_series_id INTEGER,
    blindbox_quantity INTEGER,
    price_per_unit DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    currency_type VARCHAR(20) NOT NULL CHECK (currency_type IN ('vitality_coins', 'cash')),
    min_purchase_quantity INTEGER DEFAULT 1,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'sold', 'cancelled', 'expired')),
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (card_instance_id) REFERENCES card_instances(id),
    FOREIGN KEY (blindbox_series_id) REFERENCES blindbox_series(id)
);

CREATE INDEX idx_p2p_listings_listing_id ON p2p_listings(listing_id);
CREATE INDEX idx_p2p_listings_seller_id ON p2p_listings(seller_id);
CREATE INDEX idx_p2p_listings_seller ON p2p_listings(seller_id, status);
CREATE INDEX idx_p2p_listings_item_type ON p2p_listings(item_type, status);
CREATE INDEX idx_p2p_listings_price_range ON p2p_listings(currency_type, price_per_unit, status);
CREATE INDEX idx_p2p_listings_card_instance ON p2p_listings(card_instance_id);
CREATE INDEX idx_p2p_listings_blindbox ON p2p_listings(blindbox_series_id);
CREATE INDEX idx_p2p_listings_status ON p2p_listings(status);
CREATE INDEX idx_p2p_listings_created_at ON p2p_listings(created_at);
CREATE INDEX idx_p2p_listings_expires_at ON p2p_listings(expires_at);

COMMENT ON TABLE p2p_listings IS 'P2P交易挂单表(支持卡片实例、钥匙、盲盒交易)';
COMMENT ON COLUMN p2p_listings.item_type IS '物品类型: keys, card_instance, blindbox';

-- 14. 交易记录表
CREATE TABLE p2p_transactions (
    id BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    listing_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    buyer_id VARCHAR(50) NOT NULL,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('keys', 'card_instance', 'blindbox')),
    card_instance_id BIGINT,
    keys_quantity INTEGER,
    blindbox_series_id INTEGER,
    blindbox_quantity INTEGER,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    currency_type VARCHAR(20) NOT NULL CHECK (currency_type IN ('vitality_coins', 'cash')),
    platform_fee_rate DECIMAL(5,4) DEFAULT 0.0500,
    platform_fee_amount DECIMAL(10,2) DEFAULT 0,
    seller_received DECIMAL(10,2) NOT NULL,
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    completion_time TIMESTAMP,
    failure_reason VARCHAR(200),
    ownership_transfer_completed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (card_instance_id) REFERENCES card_instances(id),
    FOREIGN KEY (blindbox_series_id) REFERENCES blindbox_series(id)
);

CREATE INDEX idx_p2p_transactions_transaction_id ON p2p_transactions(transaction_id);
CREATE INDEX idx_p2p_transactions_listing ON p2p_transactions(listing_id);
CREATE INDEX idx_p2p_transactions_seller_id ON p2p_transactions(seller_id);
CREATE INDEX idx_p2p_transactions_buyer_id ON p2p_transactions(buyer_id);
CREATE INDEX idx_p2p_transactions_seller_transactions ON p2p_transactions(seller_id, transaction_time);
CREATE INDEX idx_p2p_transactions_buyer_transactions ON p2p_transactions(buyer_id, transaction_time);
CREATE INDEX idx_p2p_transactions_status_time ON p2p_transactions(status, transaction_time);
CREATE INDEX idx_p2p_transactions_card_instance ON p2p_transactions(card_instance_id);
CREATE INDEX idx_p2p_transactions_status ON p2p_transactions(status);
CREATE INDEX idx_p2p_transactions_transaction_time ON p2p_transactions(transaction_time);

COMMENT ON TABLE p2p_transactions IS 'P2P交易记录表(记录具体交易的卡片实例等)';
COMMENT ON COLUMN p2p_transactions.platform_fee_rate IS '平台费率(5%)';

-- ========================================
-- 系统配置
-- ========================================

-- 15. 系统配置表
CREATE TABLE system_configs (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    value_type VARCHAR(20) DEFAULT 'string' CHECK (value_type IN ('string', 'number', 'boolean', 'json')),
    category VARCHAR(50) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_configs_config_key ON system_configs(config_key);
CREATE INDEX idx_system_configs_category ON system_configs(category);
CREATE INDEX idx_system_configs_is_public ON system_configs(is_public);

COMMENT ON TABLE system_configs IS '系统配置表';

-- 插入初始配置
INSERT INTO system_configs (config_key, config_value, value_type, category, description) VALUES
('calories_to_coins_ratio', '1.0', 'number', 'mining', '卡路里兑换元气币比例'),
('daily_goal_calories', '300', 'number', 'mining', '每日打卡条件卡路里'),
('max_daily_coins', '300', 'number', 'mining', '每日最高获得元气值'),
('p2p_transaction_fee_rate', '0.025', 'number', 'trading', 'P2P交易手续费率'),
('blindbox_guarantee_count', '10', 'number', 'blindbox', '盲盒保底次数'),
('card_rarity_probabilities', '{"N":0.9,"R":0.08,"SR":0.018,"SSR":0.002}', 'json', 'blindbox', '卡片稀有度概率配置');

-- ========================================
-- 数据统计和分析
-- ========================================

-- 16. 用户行为日志表
CREATE TABLE user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    activity_detail JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_activity_logs_user_id ON user_activity_logs(user_id);
CREATE INDEX idx_user_activity_logs_user_activity ON user_activity_logs(user_id, activity_type, created_at);
CREATE INDEX idx_user_activity_logs_activity_type ON user_activity_logs(activity_type);
CREATE INDEX idx_user_activity_logs_activity_time ON user_activity_logs(activity_type, created_at);
CREATE INDEX idx_user_activity_logs_created_at ON user_activity_logs(created_at);

COMMENT ON TABLE user_activity_logs IS '用户行为日志表';

-- ========================================
-- 安全和权限
-- ========================================

-- 17. 用户会话表
CREATE TABLE user_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    device_id VARCHAR(100),
    device_info JSONB,
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_session_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_user_session ON user_sessions(user_id, is_active);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);
CREATE INDEX idx_user_sessions_is_active ON user_sessions(is_active);

COMMENT ON TABLE user_sessions IS '用户会话表';

-- ========================================
-- 创建更新时间触发器函数
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有有 updated_at 字段的表添加触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_balances_updated_at BEFORE UPDATE ON user_balances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blindbox_series_updated_at BEFORE UPDATE ON blindbox_series
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_card_designs_updated_at BEFORE UPDATE ON card_designs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_card_instances_updated_at BEFORE UPDATE ON card_instances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_collections_updated_at BEFORE UPDATE ON user_collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_blindbox_card_pools_updated_at BEFORE UPDATE ON blindbox_card_pools
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_exercise_records_updated_at BEFORE UPDATE ON exercise_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_statistics_updated_at BEFORE UPDATE ON user_statistics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_p2p_listings_updated_at BEFORE UPDATE ON p2p_listings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_configs_updated_at BEFORE UPDATE ON system_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
