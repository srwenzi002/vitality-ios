package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import com.vitality.entity.converter.LowercaseEnumConverter;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 盲盒卡池配置表
 */
@Entity
@Table(name = "blindbox_card_pools", indexes = {
        @Index(name = "idx_series", columnList = "blindbox_series_id"),
        @Index(name = "idx_blindbox_card", columnList = "blindbox_series_id, card_design_id"),
        @Index(name = "idx_card_design", columnList = "card_design_id"),
        @Index(name = "idx_drop_weight", columnList = "drop_weight"),
        @Index(name = "idx_pool_type", columnList = "pool_type, is_active"),
        @Index(name = "idx_time_range", columnList = "start_time, end_time"),
        @Index(name = "idx_is_active", columnList = "is_active")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_series_card_pool", columnNames = {"blindbox_series_id", "card_design_id", "pool_type"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("blindbox_card_pools")
public class BlindboxCardPool {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "blindbox_series_id", nullable = false)
    private Integer blindboxSeriesId;

    @Column(name = "card_design_id", nullable = false)
    private Long cardDesignId;

    @Column(name = "drop_weight")
    private Integer dropWeight = 1;

    @Column(name = "guaranteed_count")
    private Integer guaranteedCount;

    @Column(name = "max_drops_per_day")
    private Integer maxDropsPerDay;

    @Column(name = "current_daily_drops")
    private Integer currentDailyDrops = 0;

    @Column(name = "pool_type")
    @Convert(converter = PoolTypeConverter.class)
    private PoolType poolType = PoolType.NORMAL;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum PoolType {
        NORMAL, GUARANTEED, SPECIAL, LIMITED
    }
    
    @Converter(autoApply = false)
    public static class PoolTypeConverter extends LowercaseEnumConverter<PoolType> {
        public PoolTypeConverter() {
            super(PoolType.class);
        }
    }
}
