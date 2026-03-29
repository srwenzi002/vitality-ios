package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 用户统计表
 */
@Entity
@Table(name = "user_statistics", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_activity", columnList = "last_exercise_date, last_checkin_date"),
        @Index(name = "idx_streaks", columnList = "current_checkin_streak, max_checkin_streak"),
        @Index(name = "idx_total_vitality", columnList = "total_vitality_coins_produced")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_statistics", columnNames = "user_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("user_statistics")
public class UserStatistics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "total_steps")
    private Long totalSteps = 0L;

    @Column(name = "total_calories", precision = 12, scale = 2)
    private BigDecimal totalCalories = BigDecimal.ZERO;

    @Column(name = "total_checkins")
    private Integer totalCheckins = 0;

    @Column(name = "total_vitality_coins_produced", precision = 15, scale = 2)
    private BigDecimal totalVitalityCoinsProduced = BigDecimal.ZERO;

    @Column(name = "current_checkin_streak")
    private Integer currentCheckinStreak = 0;

    @Column(name = "max_checkin_streak")
    private Integer maxCheckinStreak = 0;

    @Column(name = "total_cards_obtained")
    private Integer totalCardsObtained = 0;

    @Column(name = "total_draws_count")
    private Integer totalDrawsCount = 0;

    @Column(name = "total_gold_spent", precision = 12, scale = 2)
    private BigDecimal totalGoldSpent = BigDecimal.ZERO;

    @Column(name = "last_exercise_date")
    private LocalDate lastExerciseDate;

    @Column(name = "last_checkin_date")
    private LocalDate lastCheckinDate;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
