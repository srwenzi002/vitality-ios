package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.UserStatistics;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserStatisticsMapper extends BaseMapper<UserStatistics> {
}
