package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.vitality.api.dto.auth.AuthResponse;
import com.vitality.api.dto.auth.AuthBootstrapResponse;
import com.vitality.api.dto.auth.LoginRequest;
import com.vitality.api.dto.auth.RegisterRequest;
import com.vitality.application.service.AuthService;
import com.vitality.common.BusinessException;
import com.vitality.entity.CheckinRecord;
import com.vitality.entity.User;
import com.vitality.entity.UserBalance;
import com.vitality.entity.UserSession;
import com.vitality.entity.UserStatistics;
import com.vitality.infrastructure.mapper.CheckinRecordMapper;
import com.vitality.infrastructure.mapper.UserBalanceMapper;
import com.vitality.infrastructure.mapper.UserMapper;
import com.vitality.infrastructure.mapper.UserSessionMapper;
import com.vitality.infrastructure.mapper.UserStatisticsMapper;
import com.vitality.util.IdGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserMapper userMapper;
    private final UserBalanceMapper userBalanceMapper;
    private final UserStatisticsMapper userStatisticsMapper;
    private final UserSessionMapper userSessionMapper;
    private final CheckinRecordMapper checkinRecordMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        boolean emailExists = userMapper.selectCount(new LambdaQueryWrapper<User>()
                .eq(User::getEmail, request.getEmail())) > 0;
        if (emailExists) {
            throw new BusinessException("Email already exists");
        }

        boolean usernameExists = userMapper.selectCount(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, request.getUsername())) > 0;
        if (usernameExists) {
            throw new BusinessException("Username already exists");
        }

        User user = new User();
        user.setUserId(IdGenerator.generateUserId());
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setStatus(User.UserStatus.ACTIVE);
        userMapper.insert(user);

        UserBalance balance = new UserBalance();
        balance.setUserId(user.getUserId());
        balance.setVitalityCoins(BigDecimal.ZERO);
        balance.setKeysCount(0);
        balance.setGoldCoins(BigDecimal.ZERO);
        balance.setFrozenVitalityCoins(BigDecimal.ZERO);
        balance.setFrozenKeys(0);
        userBalanceMapper.insert(balance);

        UserStatistics statistics = new UserStatistics();
        statistics.setUserId(user.getUserId());
        userStatisticsMapper.insert(statistics);

        return new AuthResponse(user.getUserId(), user.getUsername(), user.getEmail());
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getEmail, request.getEmail())
                .last("LIMIT 1"));

        if (user == null || user.getPasswordHash() == null
                || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException("Invalid email or password");
        }

        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new BusinessException("Account is not active");
        }

        return new AuthResponse(user.getUserId(), user.getUsername(), user.getEmail());
    }

    @Override
    @Transactional
    public void logout(String userId) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUserId, userId)
                .last("LIMIT 1"));
        if (user == null) {
            throw new BusinessException("User not found");
        }

        userSessionMapper.update(
                null,
                new LambdaUpdateWrapper<UserSession>()
                        .eq(UserSession::getUserId, userId)
                        .eq(UserSession::getIsActive, true)
                        .set(UserSession::getIsActive, false)
                        .set(UserSession::getLastUsedAt, LocalDateTime.now())
        );
    }

    @Override
    public AuthBootstrapResponse getBootstrap(String userId) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUserId, userId)
                .last("LIMIT 1"));
        if (user == null) {
            throw new BusinessException("User not found");
        }

        UserBalance balance = userBalanceMapper.selectOne(new LambdaQueryWrapper<UserBalance>()
                .eq(UserBalance::getUserId, userId)
                .last("LIMIT 1"));
        UserStatistics statistics = userStatisticsMapper.selectOne(new LambdaQueryWrapper<UserStatistics>()
                .eq(UserStatistics::getUserId, userId)
                .last("LIMIT 1"));

        boolean checkedInToday = checkinRecordMapper.selectCount(new LambdaQueryWrapper<CheckinRecord>()
                .eq(CheckinRecord::getUserId, userId)
                .eq(CheckinRecord::getCheckinDate, LocalDate.now())) > 0;

        return new AuthBootstrapResponse(
                user.getUserId(),
                user.getUsername(),
                user.getEmail(),
                user.getStatus() == null ? null : user.getStatus().name().toLowerCase(),
                balance,
                statistics,
                checkedInToday
        );
    }
}
