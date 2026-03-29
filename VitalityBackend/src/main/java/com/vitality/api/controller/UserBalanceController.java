package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.UserBalance;
import com.vitality.application.service.UserBalanceService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user_balances")
public class UserBalanceController extends BaseController<UserBalance> {

    private final UserBalanceService userBalanceService;

    public UserBalanceController(UserBalanceService userBalanceService) {
        this.userBalanceService = userBalanceService;
    }

    @Override
    protected IService<UserBalance> service() {
        return userBalanceService;
    }
}
