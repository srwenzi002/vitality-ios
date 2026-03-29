package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 打卡记录表
 */
@Entity
@Table(name = "checkin_records", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_user_checkin", columnList = "user_id, checkin_date"),
        @Index(name = "idx_checkin_date", columnList = "checkin_date"),
        @Index(name = "idx_consecutive_days", columnList = "consecutive_days"),
        @Index(name = "idx_goal_verified", columnList = "goal_achievement_verified")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_checkin_date", columnNames = {"user_id", "checkin_date"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("checkin_records")
public class CheckinRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "checkin_date", nullable = false)
    private LocalDate checkinDate;

    @Column(name = "checkin_time")
    @CreationTimestamp
    private LocalDateTime checkinTime;

    @Column(name = "goal_achievement_verified")
    private Boolean goalAchievementVerified = false;

    @Column(name = "consecutive_days")
    private Integer consecutiveDays = 1;

    @Column(name = "max_streak_days")
    private Integer maxStreakDays = 1;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;
}
