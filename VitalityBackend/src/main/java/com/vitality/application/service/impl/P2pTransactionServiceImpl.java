package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.P2pTransaction;
import com.vitality.infrastructure.mapper.P2pTransactionMapper;
import com.vitality.application.service.P2pTransactionService;
import org.springframework.stereotype.Service;

@Service
public class P2pTransactionServiceImpl extends ServiceImpl<P2pTransactionMapper, P2pTransaction> implements P2pTransactionService {
}
