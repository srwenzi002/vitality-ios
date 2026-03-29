package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.User;
import com.vitality.application.service.UserService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController extends BaseController<User> {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @Override
    protected IService<User> service() {
        return userService;
    }
}
