package com.vitality.application.service;

import com.vitality.api.dto.exercise.SyncExerciseResponse;
import com.vitality.entity.CheckinRecord;

public interface ExerciseBizService {
    SyncExerciseResponse syncExercise(String userId);
    CheckinRecord checkin(String userId);
}
