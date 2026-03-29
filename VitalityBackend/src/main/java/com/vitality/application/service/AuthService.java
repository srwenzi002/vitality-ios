package com.vitality.application.service;

import com.vitality.api.dto.auth.AuthResponse;
import com.vitality.api.dto.auth.AuthBootstrapResponse;
import com.vitality.api.dto.auth.LoginRequest;
import com.vitality.api.dto.auth.RegisterRequest;

public interface AuthService {
    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    void logout(String userId);

    AuthBootstrapResponse getBootstrap(String userId);
}
