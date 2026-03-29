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
 * 用户收藏表
 */
@Entity
@Table(name = "user_collections", indexes = {
        @Index(name = "idx_user_id", columnList = "user_id"),
        @Index(name = "idx_user_obtained", columnList = "user_id, obtained_date"),
        @Index(name = "idx_card_instance", columnList = "card_instance_id"),
        @Index(name = "idx_obtained_method", columnList = "obtained_method"),
        @Index(name = "idx_is_locked", columnList = "is_locked")
}, uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_instance", columnNames = {"user_id", "card_instance_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("user_collections")
public class UserCollection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, length = 50)
    private String userId;

    @Column(name = "card_instance_id", nullable = false)
    private Long cardInstanceId;

    @Column(name = "obtained_method", nullable = false)
    @Convert(converter = ObtainedMethodConverter.class)
    private ObtainedMethod obtainedMethod;

    @Column(name = "obtained_date")
    @CreationTimestamp
    private LocalDateTime obtainedDate;

    @Column(name = "source_id", length = 50)
    private String sourceId;

    @Column(name = "is_locked")
    private Boolean isLocked = false;

    @Column(name = "lock_reason", length = 100)
    private String lockReason;

    @Column(name = "lock_until")
    private LocalDateTime lockUntil;

    @Column(name = "created_at", updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum ObtainedMethod {
        BLINDBOX, TRADING, REWARD, AIRDROP
    }
    
    @Converter(autoApply = false)
    public static class ObtainedMethodConverter extends LowercaseEnumConverter<ObtainedMethod> {
        public ObtainedMethodConverter() {
            super(ObtainedMethod.class);
        }
    }
}
