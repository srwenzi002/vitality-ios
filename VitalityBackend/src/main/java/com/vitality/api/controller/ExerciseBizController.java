package com.vitality.api.controller;

import com.vitality.api.dto.exercise.CheckinRequest;
import com.vitality.api.dto.exercise.SyncExerciseRequest;
import com.vitality.api.dto.exercise.SyncExerciseResponse;
import com.vitality.application.service.ExerciseBizService;
import com.vitality.common.ApiResponse;
import com.vitality.entity.CheckinRecord;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/exercise")
@RequiredArgsConstructor
public class ExerciseBizController {

    private final ExerciseBizService exerciseBizService;

    @PostMapping("/sync")
    public ApiResponse<SyncExerciseResponse> sync(@Valid @RequestBody SyncExerciseRequest request) {
        return ApiResponse.success(exerciseBizService.syncExercise(request.getUserId()));
    }

    @PostMapping("/checkin")
    public ApiResponse<CheckinRecord> checkin(@Valid @RequestBody CheckinRequest request) {
        return ApiResponse.success(exerciseBizService.checkin(request.getUserId()));
    }
}
