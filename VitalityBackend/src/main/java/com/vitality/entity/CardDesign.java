package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

/**
 * 卡片设计表
 */
@Entity
@Table(name = "card_designs", indexes = {
        @Index(name = "idx_card_code", columnList = "card_code"),
        @Index(name = "idx_series", columnList = "blindbox_series_id"),
        @Index(name = "idx_series_rarity", columnList = "blindbox_series_id, rarity"),
        @Index(name = "idx_rarity", columnList = "rarity"),
        @Index(name = "idx_asset_range", columnList = "asset_number_start, asset_number_end"),
        @Index(name = "idx_is_active", columnList = "is_active")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("card_designs")
public class CardDesign {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "card_code", unique = true, nullable = false, length = 50)
    private String cardCode;

    @Column(name = "blindbox_series_id", nullable = false)
    private Integer blindboxSeriesId;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "rarity", nullable = false)
    private Rarity rarity;

    @Column(name = "front_image_url", length = 500)
    private String frontImageUrl;

    @Column(name = "back_image_url", length = 500)
    private String backImageUrl;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "attributes", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private String attributes;

    @Column(name = "total_supply", nullable = false)
    private Integer totalSupply;

    @Column(name = "asset_number_start", nullable = false)
    private Integer assetNumberStart;

    @Column(name = "asset_number_end", nullable = false)
    private Integer assetNumberEnd;

    @Column(name = "minted_count")
    private Integer mintedCount = 0;

    @Column(name = "is_tradable")
    private Boolean isTradable = true;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum Rarity {
        N, R, SR, SSR
    }
}
