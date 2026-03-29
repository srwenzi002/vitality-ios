package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.UserCollection;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserCollectionMapper extends BaseMapper<UserCollection> {

    @Insert("""
            INSERT INTO user_collections (
              user_id, card_instance_id, obtained_method, source_id, is_locked
            ) VALUES (
              #{userId}, #{cardInstanceId}, 'blindbox', #{sourceId}, false
            )
            """)
    int insertBlindboxCollection(
            @Param("userId") String userId,
            @Param("cardInstanceId") Long cardInstanceId,
            @Param("sourceId") String sourceId
    );
}
