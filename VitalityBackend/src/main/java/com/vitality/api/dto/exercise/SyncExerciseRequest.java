package com.vitality.api.dto.exercise;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SyncExerciseRequest {
    @NotBlank(message = "userId is required")
    private String userId;

    // Client-side values are accepted for compatibility but ignored by current mock sync logic.
    private Integer steps;
    private Double calories;
    private String date;
    private Double distance;
    private Integer duration;
}
