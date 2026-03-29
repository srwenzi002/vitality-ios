package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.BalanceTransaction;
import com.vitality.infrastructure.mapper.BalanceTransactionMapper;
import com.vitality.application.service.BalanceTransactionService;
import org.springframework.stereotype.Service;

@Service
public class BalanceTransactionServiceImpl extends ServiceImpl<BalanceTransactionMapper, BalanceTransaction> implements BalanceTransactionService {
}
