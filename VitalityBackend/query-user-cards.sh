#!/bin/bash

# 查询抽卡相关信息的便捷脚本

echo "======================================"
echo "  抽卡信息查询工具"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 查询测试用户的余额
echo -e "${BLUE}📊 1. 测试用户余额信息${NC}"
echo "======================================"
docker exec -i vitality-postgres psql -U vitality_admin -d vitality_genesis << 'EOF'
SELECT 
    user_id as "用户ID",
    keys_count as "钥匙",
    gold_coins as "金币",
    vitality_coins as "活力币",
    updated_at as "更新时间"
FROM user_balances 
WHERE user_id = 'U1704441600000';
EOF
echo ""

# 2. 查询用户抽到的所有卡片
echo -e "${BLUE}📇 2. 用户拥有的所有卡片${NC}"
echo "======================================"
docker exec -i vitality-postgres psql -U vitality_admin -d vitality_genesis << 'EOF'
SELECT 
    ci.id as "卡片实例ID",
    cd.name as "卡片名称",
    cd.rarity as "稀有度",
    ci.asset_number as "资产编号",
    bs.name as "系列名称",
    ci.minted_at as "获得时间",
    uc.obtained_method as "获得方式"
FROM user_collection uc
JOIN card_instances ci ON uc.card_instance_id = ci.id
JOIN card_designs cd ON ci.card_design_id = cd.id
JOIN blindbox_series bs ON cd.blindbox_series_id = bs.id
WHERE uc.user_id = 'U1704441600000'
ORDER BY ci.minted_at DESC
LIMIT 20;
EOF
echo ""

# 3. 查询用户的抽卡历史
echo -e "${BLUE}🎲 3. 最近20次抽卡记录${NC}"
echo "======================================"
docker exec -i vitality-postgres psql -U vitality_admin -d vitality_genesis << 'EOF'
SELECT 
    dr.id as "记录ID",
    bs.name as "系列名称",
    dr.draw_type as "抽卡类型",
    dr.keys_consumed as "消耗钥匙",
    dr.price_gold_coins_consumed as "消耗金币",
    dr.total_cards as "获得卡片数",
    dr.draw_time as "抽卡时间"
FROM draw_records dr
JOIN blindbox_series bs ON dr.blindbox_series_id = bs.id
WHERE dr.user_id = 'U1704441600000'
ORDER BY dr.draw_time DESC
LIMIT 20;
EOF
echo ""

# 4. 按稀有度统计用户的卡片
echo -e "${BLUE}📈 4. 卡片稀有度统计${NC}"
echo "======================================"
docker exec -i vitality-postgres psql -U vitality_admin -d vitality_genesis << 'EOF'
SELECT 
    cd.rarity as "稀有度",
    COUNT(*) as "数量",
    ARRAY_AGG(cd.name ORDER BY ci.minted_at DESC) as "卡片列表"
FROM user_collection uc
JOIN card_instances ci ON uc.card_instance_id = ci.id
JOIN card_designs cd ON ci.card_design_id = cd.id
WHERE uc.user_id = 'U1704441600000'
GROUP BY cd.rarity
ORDER BY 
    CASE cd.rarity 
        WHEN 'SSR' THEN 1
        WHEN 'SR' THEN 2
        WHEN 'R' THEN 3
        WHEN 'N' THEN 4
    END;
EOF
echo ""

# 5. 最后一次抽到的卡片详情
echo -e "${GREEN}🎉 5. 最后抽到的卡片（最新）${NC}"
echo "======================================"
docker exec -i vitality-postgres psql -U vitality_admin -d vitality_genesis << 'EOF'
SELECT 
    ci.id as "卡片实例ID",
    cd.name as "卡片名称",
    cd.rarity as "稀有度",
    ci.asset_number as "资产编号",
    bs.name as "所属系列",
    cd.description as "描述",
    ci.minted_at as "获得时间"
FROM user_collection uc
JOIN card_instances ci ON uc.card_instance_id = ci.id
JOIN card_designs cd ON ci.card_design_id = cd.id
JOIN blindbox_series bs ON cd.blindbox_series_id = bs.id
WHERE uc.user_id = 'U1704441600000'
ORDER BY ci.minted_at DESC
LIMIT 1;
EOF
echo ""

echo -e "${YELLOW}======================================"
echo "查询完成！"
echo "======================================${NC}"
