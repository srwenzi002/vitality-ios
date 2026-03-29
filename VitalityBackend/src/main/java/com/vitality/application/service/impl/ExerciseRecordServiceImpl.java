package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.ExerciseRecord;
import com.vitality.infrastructure.mapper.ExerciseRecordMapper;
import com.vitality.application.service.ExerciseRecordService;
import org.springframework.stereotype.Service;

@Service
public class ExerciseRecordServiceImpl extends ServiceImpl<ExerciseRecordMapper, ExerciseRecord> implements ExerciseRecordService {
}
