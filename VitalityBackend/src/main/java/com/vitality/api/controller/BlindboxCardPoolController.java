package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.BlindboxCardPool;
import com.vitality.application.service.BlindboxCardPoolService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/blindbox_card_pools")
public class BlindboxCardPoolController extends BaseController<BlindboxCardPool> {

    private final BlindboxCardPoolService blindboxCardPoolService;

    public BlindboxCardPoolController(BlindboxCardPoolService blindboxCardPoolService) {
        this.blindboxCardPoolService = blindboxCardPoolService;
    }

    @Override
    protected IService<BlindboxCardPool> service() {
        return blindboxCardPoolService;
    }
}
