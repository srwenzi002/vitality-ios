package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import com.vitality.entity.converter.LowercaseEnumConverter;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 抽卡记录表
 */
@Entity
@Table(name = "draw_records", indexes = {
        @Index(name = "idx_user_draw", columnList = "user_id, draw_time"),
        @Index(name = "idx_series_draw", columnList = "blindbox_series_id, draw_time"),
        @Index(name = "idx_series", columnList = "blindbox_series_id"),
        @Index(name = "idx_draw_type", columnList = "draw_type"),
        @Index(name = "idx_guaranteed", columnList = "is_guaranteed_triggered, guaranteed_card_instance_id"),
        @Index(name = "idx_transaction_id", columnList = "transaction_id"),
        @Index(name = "idx_draw_time", columnList = "draw_time")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("draw_records")
public class DrawRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "blindbox_series_id", nullable = false)
    private Integer blindboxSeriesId;

    @Column(name = "draw_type", nullable = false)
    @Convert(converter = DrawTypeConverter.class)
    private DrawType drawType;

    @Column(name = "keys_consumed")
    private Integer keysConsumed = 0;

    @Column(name = "price_gold_coins_consumed", precision = 10, scale = 2)
    private BigDecimal priceGoldCoinsConsumed = BigDecimal.ZERO;

    @Column(name = "cards_obtained", nullable = false, columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private String cardsObtained;

    @Column(name = "total_cards", nullable = false)
    private Integer totalCards;

    @Column(name = "rarity_breakdown", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private String rarityBreakdown;

    @Column(name = "card_instances_created", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private String cardInstancesCreated;

    @Column(name = "is_guaranteed_triggered")
    private Boolean isGuaranteedTriggered = false;

    @Column(name = "guaranteed_card_instance_id")
    private Long guaranteedCardInstanceId;

    @Column(name = "draw_time")
    @CreationTimestamp
    private LocalDateTime drawTime;

    @Column(name = "transaction_id", unique = true, nullable = false, length = 50)
    private String transactionId;

    public enum DrawType {
        SINGLE, THREE, FIVE, TEN
    }
    
    @Converter(autoApply = false)
    public static class DrawTypeConverter extends LowercaseEnumConverter<DrawType> {
        public DrawTypeConverter() {
            super(DrawType.class);
        }
    }
}
