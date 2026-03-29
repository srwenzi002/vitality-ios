package com.vitality.entity;

import com.baomidou.mybatisplus.annotation.TableName;

import com.vitality.entity.converter.LowercaseEnumConverter;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 余额变动记录表
 */
@Entity
@Table(name = "balance_transactions", indexes = {
        @Index(name = "idx_user_transaction", columnList = "user_id, created_at"),
        @Index(name = "idx_transaction_id", columnList = "transaction_id"),
        @Index(name = "idx_currency_type", columnList = "currency_type"),
        @Index(name = "idx_transaction_type", columnList = "transaction_type")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("balance_transactions")
public class BalanceTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "transaction_id", unique = true, nullable = false, length = 50)
    private String transactionId;

    @Column(name = "currency_type", nullable = false)
    @Convert(converter = CurrencyTypeConverter.class)
    private CurrencyType currencyType;

    @Column(name = "transaction_type", nullable = false)
    @Convert(converter = TransactionTypeConverter.class)
    private TransactionType transactionType;

    @Column(name = "amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(name = "balance_before", nullable = false, precision = 15, scale = 2)
    private BigDecimal balanceBefore;

    @Column(name = "balance_after", nullable = false, precision = 15, scale = 2)
    private BigDecimal balanceAfter;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    public enum CurrencyType {
        VITALITY_COINS, KEYS, GOLD_COINS
    }

    public enum TransactionType {
        DRAW, CONVERT, TRADE, TRANSFER, MINING
    }
    
    @Converter(autoApply = false)
    public static class CurrencyTypeConverter extends LowercaseEnumConverter<CurrencyType> {
        public CurrencyTypeConverter() {
            super(CurrencyType.class);
        }
    }
    
    @Converter(autoApply = false)
    public static class TransactionTypeConverter extends LowercaseEnumConverter<TransactionType> {
        public TransactionTypeConverter() {
            super(TransactionType.class);
        }
    }
}
