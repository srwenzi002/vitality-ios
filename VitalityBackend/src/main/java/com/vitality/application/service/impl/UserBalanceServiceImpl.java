package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.UserBalance;
import com.vitality.infrastructure.mapper.UserBalanceMapper;
import com.vitality.application.service.UserBalanceService;
import org.springframework.stereotype.Service;

@Service
public class UserBalanceServiceImpl extends ServiceImpl<UserBalanceMapper, UserBalance> implements UserBalanceService {
}
