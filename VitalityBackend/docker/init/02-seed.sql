BEGIN;

INSERT INTO blindbox_series (series_code, name, creator, description, cover_image, cover_color, price_type, price_keys, price_gold_coins, total_cards, is_active, total_stock, sold_count, max_per_user)
VALUES ('FLUTTER_S1', 'FLUTTER Series 01', 'srwenzi', '你的第一个盲盒系列', '/images/series1/cover.png', '#FF6A00', 'keys_only', 1, 0.00, 10, TRUE, -1, 0, NULL)
ON CONFLICT (series_code) DO UPDATE SET
  name = EXCLUDED.name,
  creator = EXCLUDED.creator,
  description = EXCLUDED.description,
  cover_image = EXCLUDED.cover_image,
  cover_color = EXCLUDED.cover_color,
  price_type = EXCLUDED.price_type,
  price_keys = EXCLUDED.price_keys,
  price_gold_coins = EXCLUDED.price_gold_coins,
  total_cards = EXCLUDED.total_cards,
  is_active = EXCLUDED.is_active,
  total_stock = EXCLUDED.total_stock,
  sold_count = EXCLUDED.sold_count,
  max_per_user = EXCLUDED.max_per_user,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_N_001', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #01', 'N', '/images/series1/3c06cc41d11af8ed86888f1b624301d3.png', '/images/series1/back.png', 'FLUTTER Series 01 第 01 张卡，稀有度 N', '{}'::jsonb, 100, 10001, 10100, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_N_001'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_N_002', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #02', 'N', '/images/series1/4a5f2d49b7395f9cb06e70abf83be772.png', '/images/series1/back.png', 'FLUTTER Series 01 第 02 张卡，稀有度 N', '{}'::jsonb, 100, 10101, 10200, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_N_002'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_N_003', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #03', 'N', '/images/series1/7fc0d5faf1c0344750b36ae01c86d6ef.png', '/images/series1/back.png', 'FLUTTER Series 01 第 03 张卡，稀有度 N', '{}'::jsonb, 100, 10201, 10300, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_N_003'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_N_004', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #04', 'N', '/images/series1/9d91b21ee08b591a98878ba41e120a0c.png', '/images/series1/back.png', 'FLUTTER Series 01 第 04 张卡，稀有度 N', '{}'::jsonb, 100, 10301, 10400, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_N_004'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_R_005', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #05', 'R', '/images/series1/a176385bbc8f4a82d8c5deed0f2b061d.png', '/images/series1/back.png', 'FLUTTER Series 01 第 05 张卡，稀有度 R', '{}'::jsonb, 80, 10401, 10480, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_R_005'), 18, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_R_006', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #06', 'R', '/images/series1/bd70df3c780916e18984409dcd339714.png', '/images/series1/back.png', 'FLUTTER Series 01 第 06 张卡，稀有度 R', '{}'::jsonb, 80, 10501, 10580, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_R_006'), 18, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_R_007', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #07', 'R', '/images/series1/ccff09c6df094adc5f44338f20252ac9.png', '/images/series1/back.png', 'FLUTTER Series 01 第 07 张卡，稀有度 R', '{}'::jsonb, 80, 10601, 10680, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_R_007'), 18, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_SR_008', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #08', 'SR', '/images/series1/d2aed75787e5397cd4d62ad1aa855164.png', '/images/series1/back.png', 'FLUTTER Series 01 第 08 张卡，稀有度 SR', '{}'::jsonb, 50, 10701, 10750, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_SR_008'), 8, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_SR_009', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #09', 'SR', '/images/series1/da2f645430ba9403e498d8c85a16e169.png', '/images/series1/back.png', 'FLUTTER Series 01 第 09 张卡，稀有度 SR', '{}'::jsonb, 50, 10801, 10850, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_SR_009'), 8, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S1_SSR_010', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), 'FLUTTER Series 01 #10', 'SSR', '/images/series1/df2322d1a4a878bfeea11f9e9d841be6.png', '/images/series1/back.png', 'FLUTTER Series 01 第 10 张卡，稀有度 SSR', '{}'::jsonb, 20, 10901, 10920, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S1'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S1_SSR_010'), 3, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_series (series_code, name, creator, description, cover_image, cover_color, price_type, price_keys, price_gold_coins, total_cards, is_active, total_stock, sold_count, max_per_user)
VALUES ('FLUTTER_S2', 'FLUTTER Series 02', 'srwenzi', '第二套扩展盲盒系列', '/images/series2/cover.png', '#37D7FF', 'keys_only', 1, 0.00, 10, TRUE, -1, 0, NULL)
ON CONFLICT (series_code) DO UPDATE SET
  name = EXCLUDED.name,
  creator = EXCLUDED.creator,
  description = EXCLUDED.description,
  cover_image = EXCLUDED.cover_image,
  cover_color = EXCLUDED.cover_color,
  price_type = EXCLUDED.price_type,
  price_keys = EXCLUDED.price_keys,
  price_gold_coins = EXCLUDED.price_gold_coins,
  total_cards = EXCLUDED.total_cards,
  is_active = EXCLUDED.is_active,
  total_stock = EXCLUDED.total_stock,
  sold_count = EXCLUDED.sold_count,
  max_per_user = EXCLUDED.max_per_user,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_N_001', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #01', 'N', '/images/series2/1ad25512582beaa25f9d4434fc28a7d8.png', '/images/series2/back.png', 'FLUTTER Series 02 第 01 张卡，稀有度 N', '{}'::jsonb, 100, 20001, 20100, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_N_001'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_N_002', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #02', 'N', '/images/series2/2199211a9988643744dbb43efba55772.png', '/images/series2/back.png', 'FLUTTER Series 02 第 02 张卡，稀有度 N', '{}'::jsonb, 100, 20101, 20200, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_N_002'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_N_003', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #03', 'N', '/images/series2/2d136ca7efc0a76989d7ed8b0d451031.png', '/images/series2/back.png', 'FLUTTER Series 02 第 03 张卡，稀有度 N', '{}'::jsonb, 100, 20201, 20300, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_N_003'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_N_004', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #04', 'N', '/images/series2/3a4b7ea4b416980c697f784bd20b3fe6.png', '/images/series2/back.png', 'FLUTTER Series 02 第 04 张卡，稀有度 N', '{}'::jsonb, 100, 20301, 20400, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_N_004'), 40, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_R_005', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #05', 'R', '/images/series2/4d38e7da2bae15dce359f2325797a420.png', '/images/series2/back.png', 'FLUTTER Series 02 第 05 张卡，稀有度 R', '{}'::jsonb, 80, 20401, 20480, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_R_005'), 18, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_R_006', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #06', 'R', '/images/series2/65c2849fae6d951101a2f03534651d95.png', '/images/series2/back.png', 'FLUTTER Series 02 第 06 张卡，稀有度 R', '{}'::jsonb, 80, 20501, 20580, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_R_006'), 18, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_R_007', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #07', 'R', '/images/series2/771b47bdbc8ffd6bf6154c3ca25196d2.png', '/images/series2/back.png', 'FLUTTER Series 02 第 07 张卡，稀有度 R', '{}'::jsonb, 80, 20601, 20680, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_R_007'), 18, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_SR_008', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #08', 'SR', '/images/series2/9bedc9c1b3549fb1c3b00af335cc3832.png', '/images/series2/back.png', 'FLUTTER Series 02 第 08 张卡，稀有度 SR', '{}'::jsonb, 50, 20701, 20750, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_SR_008'), 8, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_SR_009', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #09', 'SR', '/images/series2/b32afa31845b58d210c0ba5d5f7984d4.png', '/images/series2/back.png', 'FLUTTER Series 02 第 09 张卡，稀有度 SR', '{}'::jsonb, 50, 20801, 20850, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_SR_009'), 8, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO card_designs (card_code, blindbox_series_id, name, rarity, front_image_url, back_image_url, description, attributes, total_supply, asset_number_start, asset_number_end, minted_count, is_tradable, is_active)
VALUES ('FLUTTER_S2_SSR_010', (SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), 'FLUTTER Series 02 #10', 'SSR', '/images/series2/db11ab33364f8a9e5d442cb8ca31d97d.png', '/images/series2/back.png', 'FLUTTER Series 02 第 10 张卡，稀有度 SSR', '{}'::jsonb, 20, 20901, 20920, 0, TRUE, TRUE)
ON CONFLICT (card_code) DO UPDATE SET
  blindbox_series_id = EXCLUDED.blindbox_series_id,
  name = EXCLUDED.name,
  rarity = EXCLUDED.rarity,
  front_image_url = EXCLUDED.front_image_url,
  back_image_url = EXCLUDED.back_image_url,
  description = EXCLUDED.description,
  attributes = EXCLUDED.attributes,
  total_supply = EXCLUDED.total_supply,
  asset_number_start = EXCLUDED.asset_number_start,
  asset_number_end = EXCLUDED.asset_number_end,
  is_tradable = EXCLUDED.is_tradable,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO blindbox_card_pools (blindbox_series_id, card_design_id, drop_weight, pool_type, is_active)
VALUES ((SELECT id FROM blindbox_series WHERE series_code = 'FLUTTER_S2'), (SELECT id FROM card_designs WHERE card_code = 'FLUTTER_S2_SSR_010'), 3, 'normal', TRUE)
ON CONFLICT (blindbox_series_id, card_design_id, pool_type) DO UPDATE SET
  drop_weight = EXCLUDED.drop_weight,
  is_active = EXCLUDED.is_active,
  updated_at = CURRENT_TIMESTAMP;

COMMIT;