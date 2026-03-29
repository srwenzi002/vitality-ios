package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.ExerciseRecord;
import com.vitality.application.service.ExerciseRecordService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/exercise_records")
public class ExerciseRecordController extends BaseController<ExerciseRecord> {

    private final ExerciseRecordService exerciseRecordService;

    public ExerciseRecordController(ExerciseRecordService exerciseRecordService) {
        this.exerciseRecordService = exerciseRecordService;
    }

    @Override
    protected IService<ExerciseRecord> service() {
        return exerciseRecordService;
    }
}
