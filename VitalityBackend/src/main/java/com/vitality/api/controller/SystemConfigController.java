package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.SystemConfig;
import com.vitality.application.service.SystemConfigService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/system_configs")
public class SystemConfigController extends BaseController<SystemConfig> {

    private final SystemConfigService systemConfigService;

    public SystemConfigController(SystemConfigService systemConfigService) {
        this.systemConfigService = systemConfigService;
    }

    @Override
    protected IService<SystemConfig> service() {
        return systemConfigService;
    }
}
