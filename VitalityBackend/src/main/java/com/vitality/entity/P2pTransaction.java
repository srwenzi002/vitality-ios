package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * P2P交易记录表
 */
@Entity
@Table(name = "p2p_transactions", indexes = {
        @Index(name = "idx_transaction_id", columnList = "transaction_id"),
        @Index(name = "idx_listing", columnList = "listing_id"),
        @Index(name = "idx_seller_id", columnList = "seller_id"),
        @Index(name = "idx_buyer_id", columnList = "buyer_id"),
        @Index(name = "idx_seller_transactions", columnList = "seller_id, transaction_time"),
        @Index(name = "idx_buyer_transactions", columnList = "buyer_id, transaction_time"),
        @Index(name = "idx_status_time", columnList = "status, transaction_time"),
        @Index(name = "idx_card_instance", columnList = "card_instance_id"),
        @Index(name = "idx_status", columnList = "status"),
        @Index(name = "idx_transaction_time", columnList = "transaction_time")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("p2p_transactions")
public class P2pTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "transaction_id", unique = true, nullable = false, length = 50)
    private String transactionId;

    @Column(name = "listing_id", nullable = false, length = 50)
    private String listingId;

    @Column(name = "seller_id", nullable = false, length = 50)
    private String sellerId;

    @Column(name = "buyer_id", nullable = false, length = 50)
    private String buyerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_type", nullable = false)
    private P2pListing.ItemType itemType;

    @Column(name = "card_instance_id")
    private Long cardInstanceId;

    @Column(name = "keys_quantity")
    private Integer keysQuantity;

    @Column(name = "blindbox_series_id")
    private Integer blindboxSeriesId;

    @Column(name = "blindbox_quantity")
    private Integer blindboxQuantity;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "currency_type", nullable = false)
    private P2pListing.CurrencyType currencyType;

    @Column(name = "platform_fee_rate", precision = 5, scale = 4)
    private BigDecimal platformFeeRate = new BigDecimal("0.0500");

    @Column(name = "platform_fee_amount", precision = 10, scale = 2)
    private BigDecimal platformFeeAmount = BigDecimal.ZERO;

    @Column(name = "seller_received", nullable = false, precision = 10, scale = 2)
    private BigDecimal sellerReceived;

    @Column(name = "transaction_time")
    @CreationTimestamp
    private LocalDateTime transactionTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private TransactionStatus status = TransactionStatus.PENDING;

    @Column(name = "completion_time")
    private LocalDateTime completionTime;

    @Column(name = "failure_reason", length = 200)
    private String failureReason;

    @Column(name = "ownership_transfer_completed")
    private Boolean ownershipTransferCompleted = false;

    public enum TransactionStatus {
        PENDING, COMPLETED, FAILED, REFUNDED
    }
}
