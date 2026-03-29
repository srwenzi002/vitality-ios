package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.CardDesign;
import com.vitality.application.service.CardDesignService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/card_designs")
public class CardDesignController extends BaseController<CardDesign> {

    private final CardDesignService cardDesignService;

    public CardDesignController(CardDesignService cardDesignService) {
        this.cardDesignService = cardDesignService;
    }

    @Override
    protected IService<CardDesign> service() {
        return cardDesignService;
    }
}
