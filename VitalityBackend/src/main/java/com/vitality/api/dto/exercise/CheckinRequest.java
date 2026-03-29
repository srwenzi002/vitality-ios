package com.vitality.api.dto.exercise;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CheckinRequest {
    @NotBlank(message = "userId is required")
    private String userId;
}
