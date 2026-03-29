package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.vitality.api.dto.exercise.SyncExerciseResponse;
import com.vitality.application.service.ExerciseBizService;
import com.vitality.common.BusinessException;
import com.vitality.entity.CheckinRecord;
import com.vitality.entity.ExerciseRecord;
import com.vitality.entity.User;
import com.vitality.entity.UserBalance;
import com.vitality.entity.UserStatistics;
import com.vitality.infrastructure.mapper.CheckinRecordMapper;
import com.vitality.infrastructure.mapper.ExerciseRecordMapper;
import com.vitality.infrastructure.mapper.UserBalanceMapper;
import com.vitality.infrastructure.mapper.UserMapper;
import com.vitality.infrastructure.mapper.UserStatisticsMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.concurrent.ThreadLocalRandom;

@Service
@RequiredArgsConstructor
public class ExerciseBizServiceImpl implements ExerciseBizService {

    private final UserMapper userMapper;
    private final CheckinRecordMapper checkinRecordMapper;
    private final UserStatisticsMapper userStatisticsMapper;
    private final UserBalanceMapper userBalanceMapper;
    private final ExerciseRecordMapper exerciseRecordMapper;

    @Override
    @Transactional
    public SyncExerciseResponse syncExercise(String userId) {
        LocalDate today = LocalDate.now();
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUserId, userId)
                .last("LIMIT 1"));
        if (user == null) {
            throw new BusinessException("User not found");
        }
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new BusinessException("Account is not active");
        }

        int randomSteps = ThreadLocalRandom.current().nextInt(1200, 12001);
        BigDecimal randomCalories = BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(80.0, 500.0))
                .setScale(2, RoundingMode.HALF_UP);
        BigDecimal randomCoinsAdded = BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(3.0, 30.0))
                .setScale(2, RoundingMode.HALF_UP);

        ExerciseRecord record = exerciseRecordMapper.selectOne(new LambdaQueryWrapper<ExerciseRecord>()
                .eq(ExerciseRecord::getUserId, userId)
                .eq(ExerciseRecord::getRecordDate, today)
                .last("LIMIT 1"));

        if (record == null) {
            record = new ExerciseRecord();
            record.setUserId(userId);
            record.setRecordDate(today);
            record.setStepsCount(randomSteps);
            record.setCaloriesBurned(randomCalories);
            record.setVitalityCoinsConverted(randomCoinsAdded);
            record.setConversionRate(BigDecimal.ONE);
            record.setSyncSource(ExerciseRecord.SyncSource.IOS_HEALTH);
            exerciseRecordMapper.insert(record);
        } else {
            int accumulatedSteps = (record.getStepsCount() == null ? 0 : record.getStepsCount()) + randomSteps;
            BigDecimal accumulatedCalories = (record.getCaloriesBurned() == null ? BigDecimal.ZERO : record.getCaloriesBurned())
                    .add(randomCalories);
            BigDecimal accumulatedCoins = (record.getVitalityCoinsConverted() == null ? BigDecimal.ZERO : record.getVitalityCoinsConverted())
                    .add(randomCoinsAdded);
            record.setStepsCount(accumulatedSteps);
            record.setCaloriesBurned(accumulatedCalories);
            record.setVitalityCoinsConverted(accumulatedCoins);
            record.setSyncSource(ExerciseRecord.SyncSource.IOS_HEALTH);
            exerciseRecordMapper.updateById(record);
        }

        UserBalance balance = userBalanceMapper.selectOne(new LambdaQueryWrapper<UserBalance>()
                .eq(UserBalance::getUserId, userId)
                .last("LIMIT 1"));
        if (balance == null) {
            balance = new UserBalance();
            balance.setUserId(userId);
            balance.setVitalityCoins(randomCoinsAdded);
            balance.setGoldCoins(BigDecimal.ZERO);
            balance.setFrozenVitalityCoins(BigDecimal.ZERO);
            balance.setFrozenKeys(0);
            balance.setKeysCount(0);
            userBalanceMapper.insert(balance);
        } else {
            BigDecimal currentCoins = balance.getVitalityCoins() == null ? BigDecimal.ZERO : balance.getVitalityCoins();
            balance.setVitalityCoins(currentCoins.add(randomCoinsAdded));
            userBalanceMapper.updateById(balance);
        }

        UserStatistics statistics = userStatisticsMapper.selectOne(new LambdaQueryWrapper<UserStatistics>()
                .eq(UserStatistics::getUserId, userId)
                .last("LIMIT 1"));
        if (statistics == null) {
            statistics = new UserStatistics();
            statistics.setUserId(userId);
            statistics.setTotalSteps((long) randomSteps);
            statistics.setTotalCalories(randomCalories);
            statistics.setTotalVitalityCoinsProduced(randomCoinsAdded);
            statistics.setLastExerciseDate(today);
            userStatisticsMapper.insert(statistics);
        } else {
            long currentSteps = statistics.getTotalSteps() == null ? 0L : statistics.getTotalSteps();
            BigDecimal currentCalories = statistics.getTotalCalories() == null ? BigDecimal.ZERO : statistics.getTotalCalories();
            BigDecimal currentProduced = statistics.getTotalVitalityCoinsProduced() == null
                    ? BigDecimal.ZERO : statistics.getTotalVitalityCoinsProduced();
            statistics.setTotalSteps(currentSteps + randomSteps);
            statistics.setTotalCalories(currentCalories.add(randomCalories));
            statistics.setTotalVitalityCoinsProduced(currentProduced.add(randomCoinsAdded));
            statistics.setLastExerciseDate(today);
            userStatisticsMapper.updateById(statistics);
        }

        SyncExerciseResponse response = new SyncExerciseResponse();
        response.setId(record.getId());
        response.setUserId(record.getUserId());
        response.setExerciseDate(record.getRecordDate());
        response.setSteps(record.getStepsCount());
        response.setCalories(record.getCaloriesBurned());
        response.setCoinsAdded(randomCoinsAdded);
        response.setNewBalance(balance.getVitalityCoins());
        response.setCreatedAt(record.getCreatedAt());
        response.setUpdatedAt(record.getUpdatedAt());
        return response;
    }

    @Override
    @Transactional
    public CheckinRecord checkin(String userId) {
        LocalDate today = LocalDate.now();

        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUserId, userId)
                .last("LIMIT 1"));
        if (user == null) {
            throw new BusinessException("User not found");
        }
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new BusinessException("Account is not active");
        }

        CheckinRecord exists = checkinRecordMapper.selectOne(new LambdaQueryWrapper<CheckinRecord>()
                .eq(CheckinRecord::getUserId, userId)
                .eq(CheckinRecord::getCheckinDate, today)
                .last("LIMIT 1"));
        if (exists != null) {
            throw new BusinessException("Already checked in today");
        }

        UserStatistics statistics = userStatisticsMapper.selectOne(new LambdaQueryWrapper<UserStatistics>()
                .eq(UserStatistics::getUserId, userId)
                .last("LIMIT 1"));
        if (statistics == null) {
            statistics = new UserStatistics();
            statistics.setUserId(userId);
            userStatisticsMapper.insert(statistics);
        }

        LocalDate lastCheckinDate = statistics.getLastCheckinDate();
        int previousStreak = statistics.getCurrentCheckinStreak() == null ? 0 : statistics.getCurrentCheckinStreak();
        int newStreak = (lastCheckinDate != null && lastCheckinDate.equals(today.minusDays(1)))
                ? previousStreak + 1
                : 1;
        int maxStreak = Math.max(
                statistics.getMaxCheckinStreak() == null ? 0 : statistics.getMaxCheckinStreak(),
                newStreak
        );
        int totalCheckins = (statistics.getTotalCheckins() == null ? 0 : statistics.getTotalCheckins()) + 1;

        statistics.setCurrentCheckinStreak(newStreak);
        statistics.setMaxCheckinStreak(maxStreak);
        statistics.setTotalCheckins(totalCheckins);
        statistics.setLastCheckinDate(today);
        userStatisticsMapper.updateById(statistics);

        UserBalance balance = userBalanceMapper.selectOne(new LambdaQueryWrapper<UserBalance>()
                .eq(UserBalance::getUserId, userId)
                .last("LIMIT 1"));
        if (balance == null) {
            balance = new UserBalance();
            balance.setUserId(userId);
            balance.setVitalityCoins(BigDecimal.ZERO);
            balance.setGoldCoins(BigDecimal.ZERO);
            balance.setFrozenVitalityCoins(BigDecimal.ZERO);
            balance.setFrozenKeys(0);
            balance.setKeysCount(1);
            userBalanceMapper.insert(balance);
        } else {
            int currentKeys = balance.getKeysCount() == null ? 0 : balance.getKeysCount();
            balance.setKeysCount(currentKeys + 1);
            userBalanceMapper.updateById(balance);
        }

        CheckinRecord record = new CheckinRecord();
        record.setUserId(userId);
        record.setCheckinDate(today);
        record.setCheckinTime(LocalDateTime.now());
        record.setGoalAchievementVerified(true);
        record.setConsecutiveDays(newStreak);
        record.setMaxStreakDays(maxStreak);
        record.setCreatedAt(LocalDateTime.now());
        checkinRecordMapper.insert(record);

        return record;
    }
}
