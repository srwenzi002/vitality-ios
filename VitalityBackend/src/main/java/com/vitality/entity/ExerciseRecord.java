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
 * 运动记录表
 */
@Entity
@Table(name = "exercise_records", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_user_records", columnList = "user_id, record_date"),
        @Index(name = "idx_record_date", columnList = "record_date"),
        @Index(name = "idx_sync_source", columnList = "sync_source"),
        @Index(name = "idx_created_at", columnList = "created_at")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_date", columnNames = {"user_id", "record_date"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("exercise_records")
public class ExerciseRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "record_date", nullable = false)
    private LocalDate recordDate;

    @Column(name = "steps_count")
    private Integer stepsCount = 0;

    @Column(name = "calories_burned", precision = 8, scale = 2)
    private BigDecimal caloriesBurned = BigDecimal.ZERO;

    @Column(name = "vitality_coins_converted", precision = 10, scale = 2)
    private BigDecimal vitalityCoinsConverted = BigDecimal.ZERO;

    @Column(name = "conversion_rate", precision = 8, scale = 4)
    private BigDecimal conversionRate = BigDecimal.ONE;

    @Enumerated(EnumType.STRING)
    @Column(name = "sync_source")
    private SyncSource syncSource = SyncSource.MANUAL;

    @Column(name = "raw_device_data", columnDefinition = "jsonb")
    private String rawDeviceData;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum SyncSource {
        IOS_HEALTH, ANDROID_FIT, FITBIT, GARMIN, MANUAL, OTHER
    }
}
