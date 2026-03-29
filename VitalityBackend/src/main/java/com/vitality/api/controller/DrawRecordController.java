package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.DrawRecord;
import com.vitality.application.service.DrawRecordService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/draw_records")
public class DrawRecordController extends BaseController<DrawRecord> {

    private final DrawRecordService drawRecordService;

    public DrawRecordController(DrawRecordService drawRecordService) {
        this.drawRecordService = drawRecordService;
    }

    @Override
    protected IService<DrawRecord> service() {
        return drawRecordService;
    }
}
