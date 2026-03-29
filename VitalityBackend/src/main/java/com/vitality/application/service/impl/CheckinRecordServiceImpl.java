package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.CheckinRecord;
import com.vitality.infrastructure.mapper.CheckinRecordMapper;
import com.vitality.application.service.CheckinRecordService;
import org.springframework.stereotype.Service;

@Service
public class CheckinRecordServiceImpl extends ServiceImpl<CheckinRecordMapper, CheckinRecord> implements CheckinRecordService {
}
