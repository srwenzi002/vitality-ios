package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.BlindboxSeries;
import com.vitality.infrastructure.mapper.BlindboxSeriesMapper;
import com.vitality.application.service.BlindboxSeriesService;
import org.springframework.stereotype.Service;

@Service
public class BlindboxSeriesServiceImpl extends ServiceImpl<BlindboxSeriesMapper, BlindboxSeries> implements BlindboxSeriesService {
}
