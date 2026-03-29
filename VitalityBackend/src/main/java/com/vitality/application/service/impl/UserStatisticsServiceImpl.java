package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.UserStatistics;
import com.vitality.infrastructure.mapper.UserStatisticsMapper;
import com.vitality.application.service.UserStatisticsService;
import org.springframework.stereotype.Service;

@Service
public class UserStatisticsServiceImpl extends ServiceImpl<UserStatisticsMapper, UserStatistics> implements UserStatisticsService {
}
