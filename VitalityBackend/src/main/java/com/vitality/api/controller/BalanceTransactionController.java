package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.BalanceTransaction;
import com.vitality.application.service.BalanceTransactionService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/balance_transactions")
public class BalanceTransactionController extends BaseController<BalanceTransaction> {

    private final BalanceTransactionService balanceTransactionService;

    public BalanceTransactionController(BalanceTransactionService balanceTransactionService) {
        this.balanceTransactionService = balanceTransactionService;
    }

    @Override
    protected IService<BalanceTransaction> service() {
        return balanceTransactionService;
    }
}
