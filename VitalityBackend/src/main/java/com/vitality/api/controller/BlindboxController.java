package com.vitality.api.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.vitality.common.ApiResponse;
import com.vitality.entity.BlindboxSeries;
import com.vitality.entity.BlindboxCardPool;
import com.vitality.entity.CardDesign;
import com.vitality.entity.DrawRecord;
import com.vitality.entity.User;
import com.vitality.entity.UserBalance;
import com.vitality.entity.CardInstance;
import com.vitality.entity.UserCollection;
import com.vitality.entity.UserStatistics;
import com.vitality.infrastructure.mapper.BlindboxCardPoolMapper;
import com.vitality.infrastructure.mapper.BlindboxSeriesMapper;
import com.vitality.infrastructure.mapper.CardDesignMapper;
import com.vitality.infrastructure.mapper.CardInstanceMapper;
import com.vitality.infrastructure.mapper.DrawRecordMapper;
import com.vitality.infrastructure.mapper.UserCollectionMapper;
import com.vitality.infrastructure.mapper.UserBalanceMapper;
import com.vitality.infrastructure.mapper.UserMapper;
import com.vitality.infrastructure.mapper.UserStatisticsMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import lombok.Data;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/blindbox")
@RequiredArgsConstructor
public class BlindboxController {

    private final BlindboxSeriesMapper blindboxSeriesMapper;
    private final BlindboxCardPoolMapper blindboxCardPoolMapper;
    private final CardDesignMapper cardDesignMapper;
    private final CardInstanceMapper cardInstanceMapper;
    private final UserCollectionMapper userCollectionMapper;
    private final UserMapper userMapper;
    private final UserBalanceMapper userBalanceMapper;
    private final UserStatisticsMapper userStatisticsMapper;
    private final DrawRecordMapper drawRecordMapper;
    private final ObjectMapper objectMapper;

    @GetMapping("/series/active")
    public ApiResponse<List<Map<String, Object>>> getActiveSeries() {
        LocalDateTime now = LocalDateTime.now();

        List<BlindboxSeries> activeSeries = blindboxSeriesMapper.selectList(new LambdaQueryWrapper<BlindboxSeries>()
                .eq(BlindboxSeries::getIsActive, true)
                .and(wrapper -> wrapper.isNull(BlindboxSeries::getStartTime)
                        .or()
                        .le(BlindboxSeries::getStartTime, now))
                .and(wrapper -> wrapper.isNull(BlindboxSeries::getEndTime)
                        .or()
                        .ge(BlindboxSeries::getEndTime, now))
                .orderByDesc(BlindboxSeries::getCreatedAt));

        List<Map<String, Object>> result = new ArrayList<>();
        for (BlindboxSeries series : activeSeries) {
            long cardCount = cardDesignMapper.selectCount(new LambdaQueryWrapper<CardDesign>()
                    .eq(CardDesign::getBlindboxSeriesId, series.getId())
                    .eq(CardDesign::getIsActive, true));

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", series.getId());
            item.put("name", series.getName());
            item.put("description", series.getDescription());
            item.put("totalItems", series.getTotalCards() != null && series.getTotalCards() > 0
                    ? series.getTotalCards()
                    : (int) cardCount);
            item.put("status", Boolean.TRUE.equals(series.getIsActive()) ? "active" : "inactive");
            item.put("imageUrl", series.getCoverImage());
            item.put("priceKeys", series.getPriceKeys());
            item.put("priceGoldCoins", series.getPriceGoldCoins());
            item.put("createdAt", series.getCreatedAt());
            result.add(item);
        }

        return ApiResponse.success(result);
    }

    @GetMapping("/series/{seriesId}")
    public ApiResponse<Map<String, Object>> getSeriesDetail(@PathVariable Integer seriesId) {
        BlindboxSeries series = blindboxSeriesMapper.selectById(seriesId);
        if (series == null) {
            return ApiResponse.error(404, "Series not found");
        }

        List<CardDesign> cards = cardDesignMapper.selectList(new LambdaQueryWrapper<CardDesign>()
                .eq(CardDesign::getBlindboxSeriesId, seriesId)
                .eq(CardDesign::getIsActive, true)
                .orderByAsc(CardDesign::getId));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", series.getId());
        data.put("name", series.getName());
        data.put("description", series.getDescription());
        data.put("imageUrl", series.getCoverImage());
        data.put("status", Boolean.TRUE.equals(series.getIsActive()) ? "active" : "inactive");
        data.put("totalItems", cards.size());
        data.put("priceKeys", series.getPriceKeys());
        data.put("priceGoldCoins", series.getPriceGoldCoins());

        List<Map<String, Object>> cardItems = new ArrayList<>();
        for (CardDesign card : cards) {
            Map<String, Object> cardItem = new LinkedHashMap<>();
            cardItem.put("id", card.getId());
            cardItem.put("seriesId", card.getBlindboxSeriesId());
            cardItem.put("name", card.getName());
            cardItem.put("rarity", card.getRarity() == null ? null : card.getRarity().name());
            cardItem.put("probability", 0.0);
            cardItem.put("imageUrl", card.getFrontImageUrl());
            cardItem.put("description", card.getDescription());
            cardItems.add(cardItem);
        }
        data.put("cards", cardItems);

        return ApiResponse.success(data);
    }

    @GetMapping("/collection/{userId}/series")
    public ApiResponse<List<Map<String, Object>>> getOwnedSeries(@PathVariable String userId) {
        List<UserCollection> collections = userCollectionMapper.selectList(new LambdaQueryWrapper<UserCollection>()
                .eq(UserCollection::getUserId, userId));
        if (collections.isEmpty()) {
            return ApiResponse.success(new ArrayList<>());
        }

        Set<Long> instanceIds = collections.stream()
                .map(UserCollection::getCardInstanceId)
                .collect(Collectors.toSet());
        if (instanceIds.isEmpty()) {
            return ApiResponse.success(new ArrayList<>());
        }

        List<CardInstance> instances = cardInstanceMapper.selectList(new LambdaQueryWrapper<CardInstance>()
                .in(CardInstance::getId, instanceIds));
        if (instances.isEmpty()) {
            return ApiResponse.success(new ArrayList<>());
        }

        Set<Long> designIds = instances.stream()
                .map(CardInstance::getCardDesignId)
                .collect(Collectors.toSet());
        List<CardDesign> designs = cardDesignMapper.selectList(new LambdaQueryWrapper<CardDesign>()
                .in(CardDesign::getId, designIds));
        if (designs.isEmpty()) {
            return ApiResponse.success(new ArrayList<>());
        }

        Map<Long, CardDesign> designMap = designs.stream()
                .collect(Collectors.toMap(CardDesign::getId, d -> d));
        Map<Integer, Integer> seriesOwnedInstanceCount = new HashMap<>();
        for (CardInstance instance : instances) {
            CardDesign design = designMap.get(instance.getCardDesignId());
            if (design == null) continue;
            Integer seriesId = design.getBlindboxSeriesId();
            seriesOwnedInstanceCount.put(seriesId, seriesOwnedInstanceCount.getOrDefault(seriesId, 0) + 1);
        }
        if (seriesOwnedInstanceCount.isEmpty()) {
            return ApiResponse.success(new ArrayList<>());
        }

        List<BlindboxSeries> seriesList = blindboxSeriesMapper.selectList(new LambdaQueryWrapper<BlindboxSeries>()
                .in(BlindboxSeries::getId, seriesOwnedInstanceCount.keySet())
                .orderByDesc(BlindboxSeries::getUpdatedAt));

        List<Map<String, Object>> result = new ArrayList<>();
        for (BlindboxSeries series : seriesList) {
            int ownedInstances = seriesOwnedInstanceCount.getOrDefault(series.getId(), 0);
            long totalDesigns = cardDesignMapper.selectCount(new LambdaQueryWrapper<CardDesign>()
                    .eq(CardDesign::getBlindboxSeriesId, series.getId())
                    .eq(CardDesign::getIsActive, true));
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", series.getId());
            item.put("name", series.getName());
            item.put("description", series.getDescription());
            item.put("imageUrl", series.getCoverImage());
            item.put("status", Boolean.TRUE.equals(series.getIsActive()) ? "active" : "inactive");
            item.put("totalItems", totalDesigns);
            item.put("ownedInstances", ownedInstances);
            result.add(item);
        }
        return ApiResponse.success(result);
    }

    @GetMapping("/collection/{userId}/series/{seriesId}")
    public ApiResponse<Map<String, Object>> getOwnedSeriesCollection(
            @PathVariable String userId,
            @PathVariable Integer seriesId
    ) {
        BlindboxSeries series = blindboxSeriesMapper.selectById(seriesId);
        if (series == null) {
            return ApiResponse.error(404, "Series not found");
        }

        List<CardDesign> designs = cardDesignMapper.selectList(new LambdaQueryWrapper<CardDesign>()
                .eq(CardDesign::getBlindboxSeriesId, seriesId)
                .eq(CardDesign::getIsActive, true)
                .orderByAsc(CardDesign::getId));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("id", series.getId());
        result.put("name", series.getName());
        result.put("description", series.getDescription());
        result.put("imageUrl", series.getCoverImage());
        result.put("totalItems", designs.size());

        if (designs.isEmpty()) {
            result.put("cards", new ArrayList<>());
            return ApiResponse.success(result);
        }

        Set<Long> designIds = designs.stream().map(CardDesign::getId).collect(Collectors.toSet());
        List<UserCollection> collections = userCollectionMapper.selectList(new LambdaQueryWrapper<UserCollection>()
                .eq(UserCollection::getUserId, userId));
        Set<Long> collectedInstanceIds = collections.stream()
                .map(UserCollection::getCardInstanceId)
                .collect(Collectors.toSet());

        Map<Long, Integer> ownedCountByDesignId = new HashMap<>();
        if (!collectedInstanceIds.isEmpty()) {
            List<CardInstance> instances = cardInstanceMapper.selectList(new LambdaQueryWrapper<CardInstance>()
                    .in(CardInstance::getId, collectedInstanceIds)
                    .isNotNull(CardInstance::getCardDesignId));
            for (CardInstance instance : instances) {
                Long designId = instance.getCardDesignId();
                if (!designIds.contains(designId)) continue;
                ownedCountByDesignId.put(designId, ownedCountByDesignId.getOrDefault(designId, 0) + 1);
            }
        }

        List<Map<String, Object>> cards = new ArrayList<>();
        for (CardDesign design : designs) {
            int ownedCount = ownedCountByDesignId.getOrDefault(design.getId(), 0);
            Map<String, Object> card = new LinkedHashMap<>();
            card.put("id", design.getId());
            card.put("seriesId", design.getBlindboxSeriesId());
            card.put("name", design.getName());
            card.put("rarity", design.getRarity() == null ? null : design.getRarity().name());
            card.put("imageUrl", design.getFrontImageUrl());
            card.put("description", design.getDescription());
            card.put("ownedCount", ownedCount);
            card.put("owned", ownedCount > 0);
            cards.add(card);
        }
        result.put("cards", cards);
        return ApiResponse.success(result);
    }

    @PostMapping("/draw")
    @Transactional
    public ApiResponse<Map<String, Object>> draw(@Valid @RequestBody DrawRequest request) {
        Integer count = request.getCount() == null ? 1 : request.getCount();
        if (count != 1 && count != 3 && count != 5 && count != 10) {
            return ApiResponse.error(400, "count must be one of: 1, 3, 5, 10");
        }

        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUserId, request.getUserId())
                .last("LIMIT 1"));
        if (user == null) {
            return ApiResponse.error(404, "User not found");
        }
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            return ApiResponse.error(400, "User is not active");
        }

        LocalDateTime now = LocalDateTime.now();
        BlindboxSeries series = blindboxSeriesMapper.selectOne(new LambdaQueryWrapper<BlindboxSeries>()
                .eq(BlindboxSeries::getId, request.getSeriesId())
                .eq(BlindboxSeries::getIsActive, true)
                .and(wrapper -> wrapper.isNull(BlindboxSeries::getStartTime)
                        .or()
                        .le(BlindboxSeries::getStartTime, now))
                .and(wrapper -> wrapper.isNull(BlindboxSeries::getEndTime)
                        .or()
                        .ge(BlindboxSeries::getEndTime, now))
                .last("LIMIT 1"));
        if (series == null) {
            return ApiResponse.error(404, "Blindbox series not available");
        }

        List<BlindboxCardPool> pools = blindboxCardPoolMapper.selectList(new LambdaQueryWrapper<BlindboxCardPool>()
                .eq(BlindboxCardPool::getBlindboxSeriesId, request.getSeriesId())
                .eq(BlindboxCardPool::getIsActive, true)
                .eq(BlindboxCardPool::getPoolType, BlindboxCardPool.PoolType.NORMAL)
                .and(wrapper -> wrapper.isNull(BlindboxCardPool::getStartTime)
                        .or()
                        .le(BlindboxCardPool::getStartTime, now))
                .and(wrapper -> wrapper.isNull(BlindboxCardPool::getEndTime)
                        .or()
                        .ge(BlindboxCardPool::getEndTime, now)));
        if (pools.isEmpty()) {
            return ApiResponse.error(400, "No active pool cards configured");
        }

        Map<Long, CardDesign> cardDesignMap = cardDesignMapper.selectList(new LambdaQueryWrapper<CardDesign>()
                        .in(CardDesign::getId, pools.stream().map(BlindboxCardPool::getCardDesignId).collect(Collectors.toSet()))
                        .eq(CardDesign::getIsActive, true))
                .stream()
                .collect(Collectors.toMap(CardDesign::getId, item -> item));
        pools = pools.stream()
                .filter(p -> p.getDropWeight() != null && p.getDropWeight() > 0 && cardDesignMap.containsKey(p.getCardDesignId()))
                .collect(Collectors.toList());
        if (pools.isEmpty()) {
            return ApiResponse.error(400, "No drawable cards in pool");
        }

        UserBalance balance = userBalanceMapper.selectOne(new LambdaQueryWrapper<UserBalance>()
                .eq(UserBalance::getUserId, request.getUserId())
                .last("LIMIT 1"));
        if (balance == null) {
            balance = new UserBalance();
            balance.setUserId(request.getUserId());
            balance.setVitalityCoins(BigDecimal.ZERO);
            balance.setKeysCount(0);
            balance.setGoldCoins(BigDecimal.ZERO);
            balance.setFrozenVitalityCoins(BigDecimal.ZERO);
            balance.setFrozenKeys(0);
            userBalanceMapper.insert(balance);
        }

        int keysCost = (series.getPriceKeys() == null ? 0 : series.getPriceKeys()) * count;
        BigDecimal goldCost = (series.getPriceGoldCoins() == null ? BigDecimal.ZERO : series.getPriceGoldCoins())
                .multiply(BigDecimal.valueOf(count));

        int currentKeys = balance.getKeysCount() == null ? 0 : balance.getKeysCount();
        BigDecimal currentGold = balance.getGoldCoins() == null ? BigDecimal.ZERO : balance.getGoldCoins();
        if (currentKeys < keysCost) {
            return ApiResponse.error(400, "Not enough keys");
        }
        if (currentGold.compareTo(goldCost) < 0) {
            return ApiResponse.error(400, "Not enough gold coins");
        }

        List<Map<String, Object>> drawnCards = new ArrayList<>();
        Map<String, Integer> rarityBreakdown = new HashMap<>();
        List<Long> createdInstanceIds = new ArrayList<>();
        int totalWeight = pools.stream().mapToInt(BlindboxCardPool::getDropWeight).sum();

        for (int i = 0; i < count; i++) {
            BlindboxCardPool selectedPool = weightedPick(pools, totalWeight);
            CardDesign card = cardDesignMap.get(selectedPool.getCardDesignId());

            Integer maxAssetNumber = cardInstanceMapper.selectMaxAssetNumberByDesignId(card.getId());
            int mintedBase = card.getMintedCount() == null ? 0 : card.getMintedCount();
            int nextAssetNumber = maxAssetNumber == null
                    ? card.getAssetNumberStart()
                    : (maxAssetNumber + 1);
            int mintedAfterInsert = (nextAssetNumber - card.getAssetNumberStart()) + 1;
            if (mintedAfterInsert <= 0) {
                mintedAfterInsert = mintedBase + 1;
                nextAssetNumber = card.getAssetNumberStart() + mintedBase;
            }
            if (nextAssetNumber > card.getAssetNumberEnd()) {
                return ApiResponse.error(400, "Card supply exhausted for " + card.getName());
            }
            if (card.getTotalSupply() != null && mintedAfterInsert > card.getTotalSupply()) {
                return ApiResponse.error(400, "Card supply exhausted for " + card.getName());
            }

            int inserted = cardInstanceMapper.insertMintedCardInstance(
                    card.getId(),
                    nextAssetNumber,
                    "DRW_INS_" + UUID.randomUUID().toString().replace("-", ""),
                    request.getUserId()
            );
            if (inserted <= 0) {
                return ApiResponse.error(500, "Failed to create card instance");
            }
            Long cardInstanceId = cardInstanceMapper.selectIdByDesignAndAsset(card.getId(), nextAssetNumber);
            if (cardInstanceId == null) {
                return ApiResponse.error(500, "Failed to load created card instance");
            }
            createdInstanceIds.add(cardInstanceId);

            int collectionInserted = userCollectionMapper.insertBlindboxCollection(
                    request.getUserId(),
                    cardInstanceId,
                    "DRAW_" + request.getSeriesId()
            );
            if (collectionInserted <= 0) {
                return ApiResponse.error(500, "Failed to create user collection");
            }

            cardDesignMapper.updateMintedCountIfGreater(card.getId(), mintedAfterInsert);
            card.setMintedCount(Math.max(mintedBase, mintedAfterInsert));

            Map<String, Object> cardItem = new LinkedHashMap<>();
            cardItem.put("id", card.getId());
            cardItem.put("seriesId", card.getBlindboxSeriesId());
            cardItem.put("name", card.getName());
            cardItem.put("rarity", card.getRarity() == null ? null : card.getRarity().name());
            cardItem.put("probability", selectedPool.getDropWeight() * 1.0 / totalWeight);
            cardItem.put("imageUrl", card.getFrontImageUrl());
            cardItem.put("description", card.getDescription());
            cardItem.put("cardInstanceId", cardInstanceId);
            cardItem.put("assetNumber", nextAssetNumber);
            drawnCards.add(cardItem);

            String rarity = card.getRarity() == null ? "N" : card.getRarity().name();
            rarityBreakdown.put(rarity, rarityBreakdown.getOrDefault(rarity, 0) + 1);
        }

        balance.setKeysCount(currentKeys - keysCost);
        balance.setGoldCoins(currentGold.subtract(goldCost));
        userBalanceMapper.updateById(balance);

        UserStatistics statistics = userStatisticsMapper.selectOne(new LambdaQueryWrapper<UserStatistics>()
                .eq(UserStatistics::getUserId, request.getUserId())
                .last("LIMIT 1"));
        if (statistics == null) {
            statistics = new UserStatistics();
            statistics.setUserId(request.getUserId());
            statistics.setTotalDrawsCount(count);
            statistics.setTotalCardsObtained(count);
            userStatisticsMapper.insert(statistics);
        } else {
            int totalDraws = statistics.getTotalDrawsCount() == null ? 0 : statistics.getTotalDrawsCount();
            int totalCards = statistics.getTotalCardsObtained() == null ? 0 : statistics.getTotalCardsObtained();
            statistics.setTotalDrawsCount(totalDraws + count);
            statistics.setTotalCardsObtained(totalCards + count);
            userStatisticsMapper.updateById(statistics);
        }

        String transactionId = "DRW_" + UUID.randomUUID().toString().replace("-", "");
        String drawType = resolveDrawType(count);
        String cardsObtainedJson;
        String rarityBreakdownJson;
        String cardInstancesCreatedJson;
        try {
            cardsObtainedJson = objectMapper.writeValueAsString(drawnCards);
            rarityBreakdownJson = objectMapper.writeValueAsString(rarityBreakdown);
            cardInstancesCreatedJson = objectMapper.writeValueAsString(createdInstanceIds);
        } catch (JsonProcessingException e) {
            return ApiResponse.error(500, "Failed to serialize draw result");
        }
        drawRecordMapper.insertDrawRecord(
                request.getUserId(),
                request.getSeriesId(),
                drawType,
                keysCost,
                goldCost,
                cardsObtainedJson,
                count,
                rarityBreakdownJson,
                cardInstancesCreatedJson,
                false,
                transactionId
        );

        DrawRecord savedRecord = drawRecordMapper.selectOne(new LambdaQueryWrapper<DrawRecord>()
                .eq(DrawRecord::getTransactionId, transactionId)
                .last("LIMIT 1"));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("card", drawnCards.get(0));
        result.put("cards", drawnCards);
        result.put("isDuplicate", false);
        result.put("keysUsed", keysCost);
        result.put("remainingKeys", balance.getKeysCount());
        result.put("goldUsed", goldCost);
        result.put("remainingGold", balance.getGoldCoins());
        result.put("count", count);
        result.put("drawRecordId", savedRecord == null ? null : savedRecord.getId());
        result.put("transactionId", transactionId);
        return ApiResponse.success(result);
    }

    private String resolveDrawType(int count) {
        if (count == 10) return "ten";
        if (count == 5) return "five";
        if (count == 3) return "three";
        return "single";
    }

    private BlindboxCardPool weightedPick(List<BlindboxCardPool> pools, int totalWeight) {
        int random = ThreadLocalRandom.current().nextInt(totalWeight) + 1;
        int cumulative = 0;
        for (BlindboxCardPool pool : pools) {
            cumulative += pool.getDropWeight();
            if (random <= cumulative) {
                return pool;
            }
        }
        return pools.get(pools.size() - 1);
    }

    @Data
    public static class DrawRequest {
        @NotBlank(message = "userId is required")
        private String userId;

        @Min(value = 1, message = "seriesId must be positive")
        private Integer seriesId;

        @Min(1)
        @Max(10)
        private Integer count = 1;
    }
}
