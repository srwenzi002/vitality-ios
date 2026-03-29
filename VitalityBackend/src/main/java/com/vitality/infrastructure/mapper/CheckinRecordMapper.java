package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.CheckinRecord;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CheckinRecordMapper extends BaseMapper<CheckinRecord> {
}
