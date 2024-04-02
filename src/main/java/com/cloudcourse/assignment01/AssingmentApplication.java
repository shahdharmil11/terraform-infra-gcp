package com.cloudcourse.assignment01;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Import;
import org.apache.logging.log4j.Logger;

@SpringBootApplication
@ComponentScan(basePackages = {"com.cloudcourse"})
@Import(Config.class)
public class AssingmentApplication {

    private static final Logger logger = LogManager.getLogger(AssingmentApplication.class);

    public static void main(String[] args) {

        SpringApplication.run(AssingmentApplication.class, args);
        ThreadContext.put("severity", "INFO");
        ThreadContext.put("logger","Entry in Application: Logging INFO with Logback");
        logger.info("Logging INFO with Logback");
        logger.error("Logging ERROR with Logback");
    }

}
