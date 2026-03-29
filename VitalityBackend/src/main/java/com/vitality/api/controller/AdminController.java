package com.vitality.api.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.vitality.common.ApiResponse;
import com.vitality.entity.BlindboxCardPool;
import com.vitality.entity.BlindboxSeries;
import com.vitality.entity.CardDesign;
import com.vitality.infrastructure.mapper.BlindboxCardPoolMapper;
import com.vitality.infrastructure.mapper.BlindboxSeriesMapper;
import com.vitality.infrastructure.mapper.CardDesignMapper;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * 盲盒管理后台 API
 *
 * 系列管理:
 *   GET    /admin/blindbox/series              列出所有系列（含未上架）
 *   POST   /admin/blindbox/series              创建系列
 *   PUT    /admin/blindbox/series/{id}         更新系列
 *
 * 藏品（卡片设计）管理:
 *   GET    /admin/blindbox/series/{sid}/cards  列出系列下的藏品
 *   POST   /admin/blindbox/cards               创建藏品
 *   PUT    /admin/blindbox/cards/{id}          更新藏品（含稀有度）
 *
 * 卡池管理:
 *   GET    /admin/blindbox/series/{sid}/pool   列出系列卡池
 *   POST   /admin/blindbox/pool                将藏品加入卡池
 *   PUT    /admin/blindbox/pool/{id}           调整权重/状态
 *   DELETE /admin/blindbox/pool/{id}           从卡池移除
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final BlindboxSeriesMapper blindboxSeriesMapper;
    private final CardDesignMapper cardDesignMapper;
    private final BlindboxCardPoolMapper blindboxCardPoolMapper;

    // ==================== 系列管理 ====================

    @GetMapping("/blindbox/series")
    public ApiResponse<List<BlindboxSeries>> listAllSeries() {
        List<BlindboxSeries> list = blindboxSeriesMapper.selectList(
                new LambdaQueryWrapper<BlindboxSeries>().orderByDesc(BlindboxSeries::getCreatedAt)
        );
        return ApiResponse.success(list);
    }

    @PostMapping("/blindbox/series")
    @Transactional
    public ApiResponse<BlindboxSeries> createSeries(@RequestBody CreateSeriesRequest req) {
        if (req.getSeriesCode() == null || req.getSeriesCode().isBlank()) {
            return ApiResponse.error(400, "seriesCode 不能为空");
        }
        if (req.getName() == null || req.getName().isBlank()) {
            return ApiResponse.error(400, "name 不能为空");
        }

        Long existing = blindboxSeriesMapper.selectCount(new LambdaQueryWrapper<BlindboxSeries>()
                .eq(BlindboxSeries::getSeriesCode, req.getSeriesCode()));
        if (existing > 0) {
            return ApiResponse.error(400, "系列代码已存在: " + req.getSeriesCode());
        }

        BlindboxSeries series = new BlindboxSeries();
        series.setSeriesCode(req.getSeriesCode().trim());
        series.setName(req.getName().trim());
        series.setCreator(req.getCreator() != null && !req.getCreator().isBlank() ? req.getCreator() : "管理员");
        series.setDescription(req.getDescription());
        series.setCoverImage(req.getCoverImage());
        series.setCoverColor(req.getCoverColor());
        series.setPriceType(parsePriceType(req.getPriceType()));
        series.setPriceKeys(req.getPriceKeys() != null ? req.getPriceKeys() : 1);
        series.setPriceGoldCoins(req.getPriceGoldCoins() != null ? req.getPriceGoldCoins() : BigDecimal.ZERO);
        series.setTotalStock(req.getTotalStock());
        series.setMaxPerUser(req.getMaxPerUser());
        series.setIsActive(req.getIsActive() != null ? req.getIsActive() : Boolean.TRUE);
        series.setSoldCount(0);
        series.setTotalCards(0);

        blindboxSeriesMapper.insert(series);
        return ApiResponse.success(series);
    }

    @PutMapping("/blindbox/series/{id}")
    @Transactional
    public ApiResponse<BlindboxSeries> updateSeries(@PathVariable Integer id,
                                                     @RequestBody UpdateSeriesRequest req) {
        BlindboxSeries series = blindboxSeriesMapper.selectById(id);
        if (series == null) {
            return ApiResponse.error(404, "系列不存在: " + id);
        }

        if (req.getName() != null && !req.getName().isBlank()) series.setName(req.getName());
        if (req.getCreator() != null) series.setCreator(req.getCreator());
        if (req.getDescription() != null) series.setDescription(req.getDescription());
        if (req.getCoverImage() != null) series.setCoverImage(req.getCoverImage());
        if (req.getCoverColor() != null) series.setCoverColor(req.getCoverColor());
        if (req.getPriceType() != null) series.setPriceType(parsePriceType(req.getPriceType()));
        if (req.getPriceKeys() != null) series.setPriceKeys(req.getPriceKeys());
        if (req.getPriceGoldCoins() != null) series.setPriceGoldCoins(req.getPriceGoldCoins());
        if (req.getTotalStock() != null) series.setTotalStock(req.getTotalStock());
        if (req.getMaxPerUser() != null) series.setMaxPerUser(req.getMaxPerUser());
        if (req.getIsActive() != null) series.setIsActive(req.getIsActive());

        blindboxSeriesMapper.updateById(series);
        return ApiResponse.success(series);
    }

    @DeleteMapping("/blindbox/series/{id}")
    @Transactional
    public ApiResponse<Boolean> deleteSeries(@PathVariable Integer id) {
        BlindboxSeries series = blindboxSeriesMapper.selectById(id);
        if (series == null) {
            return ApiResponse.error(404, "系列不存在: " + id);
        }
        // 软删除：下架系列，同时停用该系列所有卡池
        series.setIsActive(Boolean.FALSE);
        blindboxSeriesMapper.updateById(series);
        blindboxCardPoolMapper.update(null,
                new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<BlindboxCardPool>()
                        .eq(BlindboxCardPool::getBlindboxSeriesId, id)
                        .set(BlindboxCardPool::getIsActive, Boolean.FALSE));
        return ApiResponse.success(true);
    }

    // ==================== 藏品管理 ====================

    @GetMapping("/blindbox/series/{seriesId}/cards")
    public ApiResponse<List<CardDesign>> listCards(@PathVariable Integer seriesId) {
        List<CardDesign> cards = cardDesignMapper.selectList(new LambdaQueryWrapper<CardDesign>()
                .eq(CardDesign::getBlindboxSeriesId, seriesId)
                .orderByAsc(CardDesign::getId));
        return ApiResponse.success(cards);
    }

    @PostMapping("/blindbox/cards")
    @Transactional
    public ApiResponse<CardDesign> createCard(@RequestBody CreateCardRequest req) {
        if (req.getCardCode() == null || req.getCardCode().isBlank()) {
            return ApiResponse.error(400, "cardCode 不能为空");
        }
        if (req.getName() == null || req.getName().isBlank()) {
            return ApiResponse.error(400, "name 不能为空");
        }
        if (req.getBlindboxSeriesId() == null) {
            return ApiResponse.error(400, "blindboxSeriesId 不能为空");
        }

        BlindboxSeries series = blindboxSeriesMapper.selectById(req.getBlindboxSeriesId());
        if (series == null) {
            return ApiResponse.error(404, "系列不存在: " + req.getBlindboxSeriesId());
        }

        Long existing = cardDesignMapper.selectCount(new LambdaQueryWrapper<CardDesign>()
                .eq(CardDesign::getCardCode, req.getCardCode()));
        if (existing > 0) {
            return ApiResponse.error(400, "卡片代码已存在: " + req.getCardCode());
        }

        int supply = req.getTotalSupply() != null ? req.getTotalSupply() : 100;
        int assetStart = req.getAssetNumberStart() != null ? req.getAssetNumberStart() : 1;

        CardDesign card = new CardDesign();
        card.setCardCode(req.getCardCode().trim());
        card.setBlindboxSeriesId(req.getBlindboxSeriesId());
        card.setName(req.getName().trim());
        card.setRarity(parseRarity(req.getRarity()));
        card.setFrontImageUrl(req.getFrontImageUrl());
        card.setBackImageUrl(req.getBackImageUrl());
        card.setDescription(req.getDescription());
        card.setTotalSupply(supply);
        card.setAssetNumberStart(assetStart);
        card.setAssetNumberEnd(assetStart + supply - 1);
        card.setMintedCount(0);
        card.setIsActive(Boolean.TRUE);
        card.setIsTradable(Boolean.TRUE);

        cardDesignMapper.insert(card);

        // 如果指定了权重，自动加入卡池
        int weight = req.getDropWeight() != null ? req.getDropWeight() : 0;
        if (weight > 0) {
            BlindboxCardPool pool = new BlindboxCardPool();
            pool.setBlindboxSeriesId(req.getBlindboxSeriesId());
            pool.setCardDesignId(card.getId());
            pool.setDropWeight(weight);
            pool.setPoolType(BlindboxCardPool.PoolType.NORMAL);
            pool.setIsActive(Boolean.TRUE);
            blindboxCardPoolMapper.insert(pool);
        }

        // 更新系列藏品数量
        series.setTotalCards(series.getTotalCards() == null ? 1 : series.getTotalCards() + 1);
        blindboxSeriesMapper.updateById(series);

        return ApiResponse.success(card);
    }

    @PutMapping("/blindbox/cards/{id}")
    @Transactional
    public ApiResponse<CardDesign> updateCard(@PathVariable Long id,
                                               @RequestBody UpdateCardRequest req) {
        CardDesign card = cardDesignMapper.selectById(id);
        if (card == null) {
            return ApiResponse.error(404, "藏品不存在: " + id);
        }

        if (req.getName() != null && !req.getName().isBlank()) card.setName(req.getName());
        if (req.getRarity() != null) card.setRarity(parseRarity(req.getRarity()));
        if (req.getFrontImageUrl() != null) card.setFrontImageUrl(req.getFrontImageUrl());
        if (req.getBackImageUrl() != null) card.setBackImageUrl(req.getBackImageUrl());
        if (req.getDescription() != null) card.setDescription(req.getDescription());
        if (req.getIsActive() != null) card.setIsActive(req.getIsActive());
        if (req.getIsTradable() != null) card.setIsTradable(req.getIsTradable());

        card.setAttributes(null); // MyBatis Plus NOT_NULL策略：排除jsonb字段避免类型错误
        cardDesignMapper.updateById(card);

        // 同步更新卡池权重
        if (req.getDropWeight() != null && req.getDropWeight() > 0) {
            BlindboxCardPool existing = blindboxCardPoolMapper.selectOne(new LambdaQueryWrapper<BlindboxCardPool>()
                    .eq(BlindboxCardPool::getBlindboxSeriesId, card.getBlindboxSeriesId())
                    .eq(BlindboxCardPool::getCardDesignId, id)
                    .last("LIMIT 1"));
            if (existing != null) {
                existing.setDropWeight(req.getDropWeight());
                blindboxCardPoolMapper.updateById(existing);
            } else {
                BlindboxCardPool pool = new BlindboxCardPool();
                pool.setBlindboxSeriesId(card.getBlindboxSeriesId());
                pool.setCardDesignId(id);
                pool.setDropWeight(req.getDropWeight());
                pool.setPoolType(BlindboxCardPool.PoolType.NORMAL);
                pool.setIsActive(Boolean.TRUE);
                blindboxCardPoolMapper.insert(pool);
            }
        }

        return ApiResponse.success(card);
    }

    @DeleteMapping("/blindbox/cards/{id}")
    @Transactional
    public ApiResponse<Boolean> deleteCard(@PathVariable Long id) {
        CardDesign card = cardDesignMapper.selectById(id);
        if (card == null) {
            return ApiResponse.error(404, "藏品不存在: " + id);
        }
        // 软删除：下架藏品，同时停用对应卡池条目
        card.setIsActive(Boolean.FALSE);
        card.setAttributes(null); // MyBatis Plus NOT_NULL策略：排除jsonb字段避免类型错误
        cardDesignMapper.updateById(card);
        blindboxCardPoolMapper.update(null,
                new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<BlindboxCardPool>()
                        .eq(BlindboxCardPool::getCardDesignId, id)
                        .set(BlindboxCardPool::getIsActive, Boolean.FALSE));
        return ApiResponse.success(true);
    }

    // ==================== 卡池管理 ====================

    @GetMapping("/blindbox/series/{seriesId}/pool")
    public ApiResponse<List<BlindboxCardPool>> listPool(@PathVariable Integer seriesId) {
        List<BlindboxCardPool> pool = blindboxCardPoolMapper.selectList(new LambdaQueryWrapper<BlindboxCardPool>()
                .eq(BlindboxCardPool::getBlindboxSeriesId, seriesId)
                .orderByDesc(BlindboxCardPool::getDropWeight));
        return ApiResponse.success(pool);
    }

    @PostMapping("/blindbox/pool")
    @Transactional
    public ApiResponse<BlindboxCardPool> addToPool(@RequestBody AddPoolRequest req) {
        if (req.getBlindboxSeriesId() == null || req.getCardDesignId() == null) {
            return ApiResponse.error(400, "blindboxSeriesId 和 cardDesignId 不能为空");
        }

        Long existing = blindboxCardPoolMapper.selectCount(new LambdaQueryWrapper<BlindboxCardPool>()
                .eq(BlindboxCardPool::getBlindboxSeriesId, req.getBlindboxSeriesId())
                .eq(BlindboxCardPool::getCardDesignId, req.getCardDesignId())
                .eq(BlindboxCardPool::getPoolType, BlindboxCardPool.PoolType.NORMAL));
        if (existing > 0) {
            return ApiResponse.error(400, "该藏品已在卡池中");
        }

        BlindboxCardPool pool = new BlindboxCardPool();
        pool.setBlindboxSeriesId(req.getBlindboxSeriesId());
        pool.setCardDesignId(req.getCardDesignId());
        pool.setDropWeight(req.getDropWeight() != null ? req.getDropWeight() : 1);
        pool.setPoolType(BlindboxCardPool.PoolType.NORMAL);
        pool.setIsActive(Boolean.TRUE);

        blindboxCardPoolMapper.insert(pool);
        return ApiResponse.success(pool);
    }

    @PutMapping("/blindbox/pool/{id}")
    @Transactional
    public ApiResponse<BlindboxCardPool> updatePool(@PathVariable Long id,
                                                     @RequestBody UpdatePoolRequest req) {
        BlindboxCardPool pool = blindboxCardPoolMapper.selectById(id);
        if (pool == null) {
            return ApiResponse.error(404, "卡池条目不存在: " + id);
        }

        if (req.getDropWeight() != null) pool.setDropWeight(req.getDropWeight());
        if (req.getIsActive() != null) pool.setIsActive(req.getIsActive());

        blindboxCardPoolMapper.updateById(pool);
        return ApiResponse.success(pool);
    }

    @DeleteMapping("/blindbox/pool/{id}")
    @Transactional
    public ApiResponse<Boolean> removeFromPool(@PathVariable Long id) {
        BlindboxCardPool pool = blindboxCardPoolMapper.selectById(id);
        if (pool == null) {
            return ApiResponse.error(404, "卡池条目不存在: " + id);
        }
        blindboxCardPoolMapper.deleteById(id);
        return ApiResponse.success(true);
    }

    // ==================== 工具方法 ====================

    private BlindboxSeries.PriceType parsePriceType(String value) {
        if (value == null) return BlindboxSeries.PriceType.KEYS_ONLY;
        try {
            return BlindboxSeries.PriceType.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return BlindboxSeries.PriceType.KEYS_ONLY;
        }
    }

    private CardDesign.Rarity parseRarity(String value) {
        if (value == null) return CardDesign.Rarity.N;
        try {
            return CardDesign.Rarity.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return CardDesign.Rarity.N;
        }
    }

    // ==================== 请求 DTO ====================

    @Data
    public static class CreateSeriesRequest {
        private String seriesCode;
        private String name;
        private String creator;
        private String description;
        private String coverImage;
        private String coverColor;
        private String priceType;
        private Integer priceKeys;
        private BigDecimal priceGoldCoins;
        private Integer totalStock;
        private Integer maxPerUser;
        private Boolean isActive;
    }

    @Data
    public static class UpdateSeriesRequest {
        private String name;
        private String creator;
        private String description;
        private String coverImage;
        private String coverColor;
        private String priceType;
        private Integer priceKeys;
        private BigDecimal priceGoldCoins;
        private Integer totalStock;
        private Integer maxPerUser;
        private Boolean isActive;
    }

    @Data
    public static class CreateCardRequest {
        private Integer blindboxSeriesId;
        private String cardCode;
        private String name;
        private String rarity;
        private String frontImageUrl;
        private String backImageUrl;
        private String description;
        private Integer totalSupply;
        private Integer assetNumberStart;
        private Integer dropWeight;
    }

    @Data
    public static class UpdateCardRequest {
        private String name;
        private String rarity;
        private String frontImageUrl;
        private String backImageUrl;
        private String description;
        private Boolean isActive;
        private Boolean isTradable;
        private Integer dropWeight;
    }

    @Data
    public static class AddPoolRequest {
        private Integer blindboxSeriesId;
        private Long cardDesignId;
        private Integer dropWeight;
    }

    @Data
    public static class UpdatePoolRequest {
        private Integer dropWeight;
        private Boolean isActive;
    }
}
