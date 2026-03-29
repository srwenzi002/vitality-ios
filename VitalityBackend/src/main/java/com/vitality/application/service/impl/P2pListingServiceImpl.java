package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.P2pListing;
import com.vitality.infrastructure.mapper.P2pListingMapper;
import com.vitality.application.service.P2pListingService;
import org.springframework.stereotype.Service;

@Service
public class P2pListingServiceImpl extends ServiceImpl<P2pListingMapper, P2pListing> implements P2pListingService {
}
