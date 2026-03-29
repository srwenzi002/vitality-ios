package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.CardInstance;
import com.vitality.application.service.CardInstanceService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/card_instances")
public class CardInstanceController extends BaseController<CardInstance> {

    private final CardInstanceService cardInstanceService;

    public CardInstanceController(CardInstanceService cardInstanceService) {
        this.cardInstanceService = cardInstanceService;
    }

    @Override
    protected IService<CardInstance> service() {
        return cardInstanceService;
    }
}
