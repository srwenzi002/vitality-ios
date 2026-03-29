package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.CardDesign;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface CardDesignMapper extends BaseMapper<CardDesign> {

    @Update("""
            UPDATE card_designs
            SET minted_count = GREATEST(COALESCE(minted_count, 0), #{mintedCount})
            WHERE id = #{cardDesignId}
            """)
    int updateMintedCountIfGreater(
            @Param("cardDesignId") Long cardDesignId,
            @Param("mintedCount") Integer mintedCount
    );
}
