package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.BlindboxCardPool;
import com.vitality.infrastructure.mapper.BlindboxCardPoolMapper;
import com.vitality.application.service.BlindboxCardPoolService;
import org.springframework.stereotype.Service;

@Service
public class BlindboxCardPoolServiceImpl extends ServiceImpl<BlindboxCardPoolMapper, BlindboxCardPool> implements BlindboxCardPoolService {
}
