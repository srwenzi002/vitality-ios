package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户余额表
 */
@Entity
@Table(name = "user_balances", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_vitality_coins", columnList = "vitality_coins"),
        @Index(name = "idx_keys_count", columnList = "keys_count")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_balance", columnNames = "user_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("user_balances")
public class UserBalance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "vitality_coins", precision = 15, scale = 2)
    private BigDecimal vitalityCoins = BigDecimal.ZERO;

    @Column(name = "keys_count")
    private Integer keysCount = 0;

    @Column(name = "gold_coins", precision = 15, scale = 2)
    private BigDecimal goldCoins = BigDecimal.ZERO;

    @Column(name = "frozen_vitality_coins", precision = 15, scale = 2)
    private BigDecimal frozenVitalityCoins = BigDecimal.ZERO;

    @Column(name = "frozen_keys")
    private Integer frozenKeys = 0;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
