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
 * 卡片实例表
 */
@Entity
@Table(name = "card_instances", indexes = {
        @Index(name = "idx_card_design", columnList = "card_design_id"),
        @Index(name = "idx_owner", columnList = "current_owner_id, instance_status"),
        @Index(name = "idx_asset_number", columnList = "asset_number"),
        @Index(name = "idx_status", columnList = "instance_status"),
        @Index(name = "idx_mint_status", columnList = "instance_status, minted_at")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_design_asset", columnNames = {"card_design_id", "asset_number"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("card_instances")
public class CardInstance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "card_design_id", nullable = false)
    private Long cardDesignId;

    @Column(name = "asset_number", nullable = false)
    private Integer assetNumber;

    @Column(name = "instance_status")
    @Convert(converter = InstanceStatusConverter.class)
    private InstanceStatus instanceStatus = InstanceStatus.UNMINTED;

    @Column(name = "mint_transaction_id", length = 50)
    private String mintTransactionId;

    @Column(name = "minted_at")
    private LocalDateTime mintedAt;

    @Column(name = "current_owner_id", length = 50)
    private String currentOwnerId;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum InstanceStatus {
        UNMINTED, MINTED, BURNED
    }
    
    @Converter(autoApply = false)
    public static class InstanceStatusConverter extends LowercaseEnumConverter<InstanceStatus> {
        public InstanceStatusConverter() {
            super(InstanceStatus.class);
        }
    }
}
