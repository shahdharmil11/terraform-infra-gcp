package com.cloudcourse.assignment01.controller;

import com.cloudcourse.assignment01.AssingmentApplication;
import com.cloudcourse.assignment01.service.HealthCheckService;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.servlet.http.HttpServletRequest;

@RestController
public class HealthCheckController {

    @Autowired
    private HealthCheckService healthCheckService;

    private static final Logger logger = LogManager.getLogger(HealthCheckController.class);

    @GetMapping("/healthz")
    public ResponseEntity<Object> healthCheck(@RequestParam(required = false) Map<String, String> params,
                                              @RequestBody(required = false) Object payload, HttpServletRequest request) {
        try {
            ThreadContext.put("severity", "INFO");
            ThreadContext.put("httpMethod", request.getMethod());
            ThreadContext.put("path", request.getRequestURI());
            ThreadContext.put("logger","Inside healthcheck get method");
            logger.info("Inside healthcheck get method");

            if (payload != null || !params.isEmpty()) {
                // If payload is present, returning HTTP 400 Bad Request
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .header("Cache-Control", "no-cache")
                        .build();
            }

            // Performing health check by checking database connectivity
            boolean isDatabaseConnected = healthCheckService.isDatabaseConnected();

            if (isDatabaseConnected) {
                // If successful, returning HTTP 200 OK
                return ResponseEntity.ok()
                        .header("Cache-Control", "no-cache")
                        .build();
            } else {
                // If unsuccessful, returning HTTP 503 Service Unavailable
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .header("Cache-Control", "no-cache")
                        .build();
            }
        } catch (Exception e) {
            e.fillInStackTrace();
            ThreadContext.put("severity", "INFO");
            ThreadContext.put("httpMethod", request.getMethod());
            ThreadContext.put("path", request.getRequestURI());
            ThreadContext.put("logger","Exception inside healthcheck Get method");
            ThreadContext.put("exception", e.getMessage());
            logger.info("Exception inside healthcheck Get method");
            System.out.println("Error has occured" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("Cache-Control", "no-cache")
                    .build();
        }
    }

    // Handling 405 Method Not Allowed
    @RequestMapping(value = "/healthz", method = {RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.HEAD, RequestMethod.PATCH, RequestMethod.TRACE, RequestMethod.OPTIONS})
    public ResponseEntity<Object> handleMethodNotAllowed() {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .header("Cache-Control", "no-cache")
                .build();
    }

    // Handling 404 Not Found, for all routes other than defined one
    @RequestMapping("/**")
    public ResponseEntity<Object> handleNotFound() {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .header("Cache-Control", "no-cache")
                .build();
    }


}

