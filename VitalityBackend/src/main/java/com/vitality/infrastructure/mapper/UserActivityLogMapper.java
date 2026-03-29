package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.UserActivityLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserActivityLogMapper extends BaseMapper<UserActivityLog> {
}
