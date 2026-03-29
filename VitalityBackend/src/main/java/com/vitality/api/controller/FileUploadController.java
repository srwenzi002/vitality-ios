package com.vitality.api.controller;

import com.vitality.common.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@RestController
@RequestMapping("/upload")
public class FileUploadController {

    @Value("${app.upload.dir:./uploads}")
    private String uploadDir;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    @PostMapping
    public ApiResponse<String> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", defaultValue = "images") String folder
    ) throws IOException {
        if (file.isEmpty()) {
            return ApiResponse.error("文件不能为空");
        }

        String originalName = file.getOriginalFilename();
        String extension = (originalName != null && originalName.contains("."))
                ? originalName.substring(originalName.lastIndexOf(".")).toLowerCase()
                : ".png";

        String fileName = UUID.randomUUID().toString().replace("-", "") + extension;
        Path targetDir = Paths.get(uploadDir, folder).toAbsolutePath();
        Files.createDirectories(targetDir);
        file.transferTo(targetDir.resolve(fileName));

        String url = "/uploads/" + folder + "/" + fileName;
        return ApiResponse.success(url);
    }
}
