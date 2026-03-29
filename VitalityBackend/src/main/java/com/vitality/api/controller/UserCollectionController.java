package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.UserCollection;
import com.vitality.application.service.UserCollectionService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user_collections")
public class UserCollectionController extends BaseController<UserCollection> {

    private final UserCollectionService userCollectionService;

    public UserCollectionController(UserCollectionService userCollectionService) {
        this.userCollectionService = userCollectionService;
    }

    @Override
    protected IService<UserCollection> service() {
        return userCollectionService;
    }
}
