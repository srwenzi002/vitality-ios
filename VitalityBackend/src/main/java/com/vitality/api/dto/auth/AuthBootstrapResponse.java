package com.vitality.api.dto.auth;

import com.vitality.entity.UserBalance;
import com.vitality.entity.UserStatistics;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthBootstrapResponse {
    private String userId;
    private String username;
    private String email;
    private String status;
    private UserBalance balance;
    private UserStatistics statistics;
    private boolean checkedInToday;
}
