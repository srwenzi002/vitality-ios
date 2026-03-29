package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.DrawRecord;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface DrawRecordMapper extends BaseMapper<DrawRecord> {

    @Insert("""
            INSERT INTO draw_records (
              user_id, blindbox_series_id, draw_type, keys_consumed, price_gold_coins_consumed,
              cards_obtained, total_cards, rarity_breakdown, card_instances_created,
              is_guaranteed_triggered, transaction_id
            ) VALUES (
              #{userId}, #{seriesId}, #{drawType}, #{keysConsumed}, #{goldConsumed},
              CAST(#{cardsObtained} AS jsonb), #{totalCards}, CAST(#{rarityBreakdown} AS jsonb),
              CAST(#{cardInstancesCreated} AS jsonb), #{isGuaranteedTriggered}, #{transactionId}
            )
            """)
    int insertDrawRecord(
            @Param("userId") String userId,
            @Param("seriesId") Integer seriesId,
            @Param("drawType") String drawType,
            @Param("keysConsumed") Integer keysConsumed,
            @Param("goldConsumed") java.math.BigDecimal goldConsumed,
            @Param("cardsObtained") String cardsObtained,
            @Param("totalCards") Integer totalCards,
            @Param("rarityBreakdown") String rarityBreakdown,
            @Param("cardInstancesCreated") String cardInstancesCreated,
            @Param("isGuaranteedTriggered") Boolean isGuaranteedTriggered,
            @Param("transactionId") String transactionId
    );
}
