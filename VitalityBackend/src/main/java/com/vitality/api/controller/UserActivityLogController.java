package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.UserActivityLog;
import com.vitality.application.service.UserActivityLogService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user_activity_logs")
public class UserActivityLogController extends BaseController<UserActivityLog> {

    private final UserActivityLogService userActivityLogService;

    public UserActivityLogController(UserActivityLogService userActivityLogService) {
        this.userActivityLogService = userActivityLogService;
    }

    @Override
    protected IService<UserActivityLog> service() {
        return userActivityLogService;
    }
}
