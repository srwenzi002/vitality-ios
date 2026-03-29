package com.vitality;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.mybatis.spring.annotation.MapperScan;

@SpringBootApplication
@MapperScan("com.vitality.infrastructure.mapper")
public class VitalityBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(VitalityBackendApplication.class, args);
    }

}
