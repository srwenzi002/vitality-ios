package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.UserActivityLog;
import com.vitality.infrastructure.mapper.UserActivityLogMapper;
import com.vitality.application.service.UserActivityLogService;
import org.springframework.stereotype.Service;

@Service
public class UserActivityLogServiceImpl extends ServiceImpl<UserActivityLogMapper, UserActivityLog> implements UserActivityLogService {
}
