package com.vitality.api.controller;

import com.baomidou.mybatisplus.extension.service.IService;
import com.vitality.entity.CheckinRecord;
import com.vitality.application.service.CheckinRecordService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/checkin_records")
public class CheckinRecordController extends BaseController<CheckinRecord> {

    private final CheckinRecordService checkinRecordService;

    public CheckinRecordController(CheckinRecordService checkinRecordService) {
        this.checkinRecordService = checkinRecordService;
    }

    @Override
    protected IService<CheckinRecord> service() {
        return checkinRecordService;
    }
}
