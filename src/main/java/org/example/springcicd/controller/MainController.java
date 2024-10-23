package org.example.springcicd.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MainController {

    @GetMapping
    public String greetings() {
        return "Hello from CI/CD project!";
    }

}
