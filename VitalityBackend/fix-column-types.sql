-- 修复列类型不匹配问题
-- 将 blindbox_series.id 从 INTEGER 改为 BIGINT

-- 1. 修改 blindbox_series 表的 id 列类型
ALTER TABLE blindbox_series ALTER COLUMN id TYPE BIGINT;

-- 2. 修改引用 blindbox_series_id 的表
ALTER TABLE blindbox_card_pools ALTER COLUMN blindbox_series_id TYPE BIGINT;
ALTER TABLE card_designs ALTER COLUMN blindbox_series_id TYPE BIGINT;
ALTER TABLE draw_records ALTER COLUMN blindbox_series_id TYPE BIGINT;

-- 验证修改
SELECT 
    table_name, 
    column_name, 
    data_type 
FROM information_schema.columns 
WHERE table_name IN ('blindbox_series', 'blindbox_card_pools', 'card_designs', 'draw_records')
  AND column_name IN ('id', 'blindbox_series_id')
ORDER BY table_name, column_name;
