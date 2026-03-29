package com.vitality.api.controller;

import com.vitality.api.dto.auth.AuthResponse;
import com.vitality.api.dto.auth.AuthBootstrapResponse;
import com.vitality.api.dto.auth.LoginRequest;
import com.vitality.api.dto.auth.LogoutRequest;
import com.vitality.api.dto.auth.RegisterRequest;
import com.vitality.application.service.AuthService;
import com.vitality.common.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ApiResponse<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.success(authService.register(request));
    }

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success(authService.login(request));
    }

    @PostMapping("/logout")
    public ApiResponse<Boolean> logout(@Valid @RequestBody LogoutRequest request) {
        authService.logout(request.getUserId());
        return ApiResponse.success(true);
    }

    @GetMapping("/bootstrap/{userId}")
    public ApiResponse<AuthBootstrapResponse> bootstrap(@PathVariable String userId) {
        return ApiResponse.success(authService.getBootstrap(userId));
    }
}
