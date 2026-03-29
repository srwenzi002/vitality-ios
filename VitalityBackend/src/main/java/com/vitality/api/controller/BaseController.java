package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.common.ApiResponse;
import org.springframework.web.bind.annotation.*;

import java.lang.reflect.Field;
import java.io.Serializable;
import java.util.List;

/**
 * Generic CRUD controller for MyBatis-Plus services.
 */
public abstract class BaseController<T> {

    protected abstract IService<T> service();

    @PostMapping
    public ApiResponse<Boolean> create(@RequestBody T entity) {
        return ApiResponse.success(service().save(entity));
    }

    @PutMapping("/{id}")
    public ApiResponse<Boolean> update(@PathVariable Long id, @RequestBody T entity) {
        setIdField(entity, id);
        return ApiResponse.success(service().updateById(entity));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> delete(@PathVariable Serializable id) {
        return ApiResponse.success(service().removeById(id));
    }

    @GetMapping("/{id}")
    public ApiResponse<T> getById(@PathVariable Serializable id) {
        return ApiResponse.success(service().getById(id));
    }

    @GetMapping
    public ApiResponse<List<T>> list() {
        return ApiResponse.success(service().list());
    }

    private void setIdField(T entity, Long id) {
        try {
            Field field = entity.getClass().getDeclaredField("id");
            field.setAccessible(true);
            if (field.getType().equals(Integer.class)) {
                field.set(entity, id.intValue());
            } else {
                field.set(entity, id);
            }
        } catch (NoSuchFieldException | IllegalAccessException e) {
            throw new IllegalArgumentException("Entity id field is required for update.", e);
        }
    }
}
