package com.vitality.application.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.vitality.entity.UserCollection;
import com.vitality.infrastructure.mapper.UserCollectionMapper;
import com.vitality.application.service.UserCollectionService;
import org.springframework.stereotype.Service;

@Service
public class UserCollectionServiceImpl extends ServiceImpl<UserCollectionMapper, UserCollection> implements UserCollectionService {
}
