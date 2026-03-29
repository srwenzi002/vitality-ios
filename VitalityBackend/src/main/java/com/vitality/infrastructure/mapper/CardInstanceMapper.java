package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.CardInstance;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CardInstanceMapper extends BaseMapper<CardInstance> {

    @Insert("""
            INSERT INTO card_instances (
              card_design_id, asset_number, instance_status, mint_transaction_id, minted_at, current_owner_id
            ) VALUES (
              #{cardDesignId}, #{assetNumber}, 'minted', #{transactionId}, CURRENT_TIMESTAMP, #{ownerId}
            )
            """)
    int insertMintedCardInstance(
            @Param("cardDesignId") Long cardDesignId,
            @Param("assetNumber") Integer assetNumber,
            @Param("transactionId") String transactionId,
            @Param("ownerId") String ownerId
    );

    @Select("""
            SELECT id
            FROM card_instances
            WHERE card_design_id = #{cardDesignId} AND asset_number = #{assetNumber}
            LIMIT 1
            """)
    Long selectIdByDesignAndAsset(
            @Param("cardDesignId") Long cardDesignId,
            @Param("assetNumber") Integer assetNumber
    );

    @Select("""
            SELECT MAX(asset_number)
            FROM card_instances
            WHERE card_design_id = #{cardDesignId}
            """)
    Integer selectMaxAssetNumberByDesignId(@Param("cardDesignId") Long cardDesignId);
}
