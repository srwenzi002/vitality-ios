package com.vitality.entity.converter;

import jakarta.persistence.AttributeConverter;

/**
 * 通用的枚举转换器基类
 * 数据库使用小写下划线格式，Java使用大写下划线格式
 * 例如：数据库中是 "keys_only"，Java枚举是 KEYS_ONLY
 */
public abstract class LowercaseEnumConverter<E extends Enum<E>> implements AttributeConverter<E, String> {
    
    private final Class<E> enumClass;
    
    protected LowercaseEnumConverter(Class<E> enumClass) {
        this.enumClass = enumClass;
    }
    
    @Override
    public String convertToDatabaseColumn(E attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.name().toLowerCase();
    }
    
    @Override
    public E convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        return Enum.valueOf(enumClass, dbData.toUpperCase());
    }
}
