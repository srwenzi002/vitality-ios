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
 * 盲盒系列表
 */
@Entity
@Table(name = "blindbox_series", indexes = {
        @Index(name = "idx_series_code", columnList = "series_code"),
        @Index(name = "idx_creator", columnList = "creator"),
        @Index(name = "idx_active_time", columnList = "is_active, start_time, end_time"),
        @Index(name = "idx_price_type", columnList = "price_type"),
        @Index(name = "idx_created_at", columnList = "created_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("blindbox_series")
public class BlindboxSeries {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "series_code", unique = true, nullable = false, length = 50)
    private String seriesCode;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "creator", nullable = false, length = 100)
    private String creator;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "cover_image", length = 500)
    private String coverImage;

    @Column(name = "cover_color", length = 50)
    private String coverColor;

    @Column(name = "price_type")
    @Convert(converter = PriceTypeConverter.class)
    private PriceType priceType = PriceType.KEYS_ONLY;

    @Column(name = "price_keys", nullable = false)
    private Integer priceKeys;

    @Column(name = "price_gold_coins", precision = 10, scale = 2)
    private BigDecimal priceGoldCoins = BigDecimal.ZERO;

    @Column(name = "total_cards")
    private Integer totalCards = 0;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "total_stock")
    private Integer totalStock;

    @Column(name = "sold_count")
    private Integer soldCount = 0;

    @Column(name = "max_per_user")
    private Integer maxPerUser;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum PriceType {
        KEYS_ONLY, KEYS_AND_CASH, CASH_ONLY
    }
    
    /**
     * 价格类型转换器：数据库使用小写下划线格式，Java使用大写下划线格式
     */
    @Converter(autoApply = false)
    public static class PriceTypeConverter implements AttributeConverter<PriceType, String> {
        @Override
        public String convertToDatabaseColumn(PriceType attribute) {
            if (attribute == null) {
                return null;
            }
            return attribute.name().toLowerCase();
        }

        @Override
        public PriceType convertToEntityAttribute(String dbData) {
            if (dbData == null) {
                return null;
            }
            return PriceType.valueOf(dbData.toUpperCase());
        }
    }
}
