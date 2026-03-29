package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.P2pTransaction;
import com.vitality.application.service.P2pTransactionService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/p2p_transactions")
public class P2pTransactionController extends BaseController<P2pTransaction> {

    private final P2pTransactionService p2pTransactionService;

    public P2pTransactionController(P2pTransactionService p2pTransactionService) {
        this.p2pTransactionService = p2pTransactionService;
    }

    @Override
    protected IService<P2pTransaction> service() {
        return p2pTransactionService;
    }
}
