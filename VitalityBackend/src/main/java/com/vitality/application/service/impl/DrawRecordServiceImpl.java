package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.DrawRecord;
import com.vitality.infrastructure.mapper.DrawRecordMapper;
import com.vitality.application.service.DrawRecordService;
import org.springframework.stereotype.Service;

@Service
public class DrawRecordServiceImpl extends ServiceImpl<DrawRecordMapper, DrawRecord> implements DrawRecordService {
}
