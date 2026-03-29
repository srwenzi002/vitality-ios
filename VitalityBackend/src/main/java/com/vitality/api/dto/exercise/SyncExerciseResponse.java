package com.vitality.api.dto.exercise;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class SyncExerciseResponse {
    private Long id;
    private String userId;
    private LocalDate exerciseDate;
    private Integer steps;
    private BigDecimal calories;
    private Double distance;
    private Integer duration;
    private BigDecimal coinsAdded;
    private BigDecimal newBalance;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
