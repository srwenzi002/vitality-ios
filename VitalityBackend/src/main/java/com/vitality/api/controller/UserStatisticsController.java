package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.UserStatistics;
import com.vitality.application.service.UserStatisticsService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user_statistics")
public class UserStatisticsController extends BaseController<UserStatistics> {

    private final UserStatisticsService userStatisticsService;

    public UserStatisticsController(UserStatisticsService userStatisticsService) {
        this.userStatisticsService = userStatisticsService;
    }

    @Override
    protected IService<UserStatistics> service() {
        return userStatisticsService;
    }
}
