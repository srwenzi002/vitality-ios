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
 * P2P交易挂单表
 */
@Entity
@Table(name = "p2p_listings", indexes = {
        @Index(name = "idx_listing_id", columnList = "listing_id"),
        @Index(name = "idx_seller_id", columnList = "seller_id"),
        @Index(name = "idx_seller", columnList = "seller_id, status"),
        @Index(name = "idx_item_type", columnList = "item_type, status"),
        @Index(name = "idx_price_range", columnList = "currency_type, price_per_unit, status"),
        @Index(name = "idx_card_instance", columnList = "card_instance_id"),
        @Index(name = "idx_blindbox", columnList = "blindbox_series_id"),
        @Index(name = "idx_status", columnList = "status"),
        @Index(name = "idx_created_at", columnList = "created_at"),
        @Index(name = "idx_expires_at", columnList = "expires_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("p2p_listings")
public class P2pListing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "listing_id", unique = true, nullable = false, length = 50)
    private String listingId;

    @Column(name = "seller_id", nullable = false, length = 50)
    private String sellerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_type", nullable = false)
    private ItemType itemType;

    @Column(name = "card_instance_id")
    private Long cardInstanceId;

    @Column(name = "keys_quantity")
    private Integer keysQuantity;

    @Column(name = "blindbox_series_id")
    private Integer blindboxSeriesId;

    @Column(name = "blindbox_quantity")
    private Integer blindboxQuantity;

    @Column(name = "price_per_unit", nullable = false, precision = 10, scale = 2)
    private BigDecimal pricePerUnit;

    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Enumerated(EnumType.STRING)
    @Column(name = "currency_type", nullable = false)
    private CurrencyType currencyType;

    @Column(name = "min_purchase_quantity")
    private Integer minPurchaseQuantity = 1;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private ListingStatus status = ListingStatus.ACTIVE;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum ItemType {
        KEYS, CARD_INSTANCE, BLINDBOX
    }

    public enum CurrencyType {
        VITALITY_COINS, CASH
    }

    public enum ListingStatus {
        ACTIVE, SOLD, CANCELLED, EXPIRED
    }
}
