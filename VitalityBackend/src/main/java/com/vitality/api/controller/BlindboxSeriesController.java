package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.BlindboxSeries;
import com.vitality.application.service.BlindboxSeriesService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/blindbox_series")
public class BlindboxSeriesController extends BaseController<BlindboxSeries> {

    private final BlindboxSeriesService blindboxSeriesService;

    public BlindboxSeriesController(BlindboxSeriesService blindboxSeriesService) {
        this.blindboxSeriesService = blindboxSeriesService;
    }

    @Override
    protected IService<BlindboxSeries> service() {
        return blindboxSeriesService;
    }
}
