package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.P2pListing;
import com.vitality.application.service.P2pListingService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/p2p_listings")
public class P2pListingController extends BaseController<P2pListing> {

    private final P2pListingService p2pListingService;

    public P2pListingController(P2pListingService p2pListingService) {
        this.p2pListingService = p2pListingService;
    }

    @Override
    protected IService<P2pListing> service() {
        return p2pListingService;
    }
}
