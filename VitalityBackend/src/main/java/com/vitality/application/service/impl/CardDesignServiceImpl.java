package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.CardDesign;
import com.vitality.infrastructure.mapper.CardDesignMapper;
import com.vitality.application.service.CardDesignService;
import org.springframework.stereotype.Service;

@Service
public class CardDesignServiceImpl extends ServiceImpl<CardDesignMapper, CardDesign> implements CardDesignService {
}
