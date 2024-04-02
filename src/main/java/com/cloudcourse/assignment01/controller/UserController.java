package com.cloudcourse.assignment01.controller;

import com.cloudcourse.assignment01.dao.UserDao;
import com.cloudcourse.assignment01.dao.UserInfoDTO;
import com.cloudcourse.assignment01.model.User;
import com.cloudcourse.assignment01.service.UserService;
import com.cloudcourse.assignment01.service.PubSubService;
import com.google.api.core.ApiFuture;
import com.google.api.core.ApiFutureCallback;
import com.google.api.core.ApiFutures;
import com.google.api.gax.rpc.ApiException;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.TopicName;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.ThreadContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import com.google.gson.JsonObject;

@RestController
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private UserDao userDao;

    @Autowired
    private PubSubService pubSubService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    private static final Logger logger = LogManager.getLogger(UserController.class);

    @PostMapping("/v1/user")
    public ResponseEntity<Object> createUser(@RequestBody User user, HttpServletRequest request) {
        try {

            ThreadContext.put("severity", "INFO");
            ThreadContext.put("httpMethod", request.getMethod());
            ThreadContext.put("path", request.getRequestURI());
            ThreadContext.put("logger", "Logging INFO with user controller post method" + user.getEmail());
            logger.info("Logging INFO with user controller post method");

            ThreadContext.put("severity", "WARNING");
            ThreadContext.put("httpMethod", request.getMethod());
            ThreadContext.put("path", request.getRequestURI());
            ThreadContext.put("logger", "Logging Warning with user controller post method" + user.getEmail());
            logger.info("Logging Warning with user controller post method");

            logger.info("Logging INFO user controller CREATE " + user.getEmail());
            if ((!userDao.findByEmail(user.getEmail()).isPresent()) && user.getEmail() != null && !user.getEmail().isEmpty()) {
                User createdUser = userService.createUser(user);
                UserInfoDTO userInfoDTO = createdUser.toUserInfoDTO();
                //publishWithErrorHandlerExample(projectId, topicId, user.getEmail(), user.getId().toString());
                pubSubService.publishUserInformation(user);
                return new ResponseEntity<>(userInfoDTO, HttpStatus.CREATED);
            } else {
                // User with the same email already exists, return 400 Bad Request
                ThreadContext.put("severity", "ERROR");
                ThreadContext.put("httpMethod", request.getMethod());
                ThreadContext.put("path", request.getRequestURI());
                logger.error("Invalid User Create Operation: Bad Request");

                return new ResponseEntity<>("Email already exist",HttpStatus.BAD_REQUEST);
            }
        } catch (IllegalArgumentException e) {
            // Handle validation errors
            ThreadContext.put("severity", "ERROR");
            ThreadContext.put("httpMethod", request.getMethod());
            ThreadContext.put("path", request.getRequestURI());
            logger.error("Invalid User Create Operation: " + e.getMessage());

            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            e.fillInStackTrace();

            ThreadContext.put("severity", "ERROR");
            ThreadContext.put("httpMethod", request.getMethod());
            ThreadContext.put("path", request.getRequestURI());
            logger.error("Invalid User Create Operation: " + e.getMessage());

            logger.error("Logging ERROR with user controller post method");
            System.out.println("Error has occured" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("Cache-Control", "no-cache")
                    .build();
        }
    }

    @PutMapping(value = "/v1/user/self")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> updateUser(@RequestParam(required = false) Map<String, String> params,
                                             @RequestBody User updatedUser) {
        try {
            logger.info("Logging INFO with user controller put method");
            if (!params.isEmpty() || updatedUser == null || updatedUser.getEmail() != null) {
                // If payload is present, returning HTTP 400 Bad Request
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .header("Cache-Control", "no-cache")
                        .build();
            }

            String userEmail = SecurityContextHolder.getContext().getAuthentication().getName();
            User existingUser = userService.getUserByEmail(userEmail);

            if (existingUser.getStatus()=="Created") {
                return new ResponseEntity<>("User email is not verified", HttpStatus.BAD_REQUEST);
            } else if (existingUser.getStatus()=="Expired") {
                return new ResponseEntity<>("User email is expired", HttpStatus.BAD_REQUEST);
            }

            User updatedUserData = userService.updateUser(existingUser, updatedUser);
            UserInfoDTO user = updatedUserData.toUserInfoDTO();
            return new ResponseEntity<>("user data is updated" + user.toString(), HttpStatus.OK);
        } catch (HttpMessageNotReadableException e) {
            // Handle incorrect JSON in the request
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Invalid JSON format in request body.");
        } catch (IllegalArgumentException e) {
            // Handle validation errors
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (RuntimeException e) {
            return new ResponseEntity<>("user data is not sufficient, please fill in required fields", HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            e.fillInStackTrace();
            System.out.println("Error has occured" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("Cache-Control", "no-cache")
                    .build();
        }
    }

//    @GetMapping(value = "/v1/user/email-tracker")
//    @PreAuthorize("isAuthenticated()")
//    public ResponseEntity<Object> emailTrackerDetails(@RequestParam("id") String id) {
//        return userService.emailTrackerDetails(id);
//    }

    @GetMapping(value = "/v1/user/verify")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> verifyUser(@RequestParam("email") String email, @RequestParam("id") String id) {

        if (email==null || id == null) {
            return new ResponseEntity<>("Improper credentials provided", HttpStatus.BAD_REQUEST);
        }

        User existingUser = userService.getUserByEmail(email);

        if (existingUser.getId().toString().equals(id)) {
            if(existingUser.getStatus().equals("Created") && userService.verifyUser(existingUser)) {
                //boolean updatedUserData = userService.verifyUser(existingUser);
                return new ResponseEntity<>("user email is verified", HttpStatus.OK);
            } else if(existingUser.getStatus().equals("Expired")) {
                return new ResponseEntity<>("user email is expired", HttpStatus.BAD_REQUEST);
            } else if(existingUser.getStatus().equals("Created")) {
                return new ResponseEntity<>("User email is not verified", HttpStatus.BAD_REQUEST);
            } else {
                return new ResponseEntity<>("Wrong token", HttpStatus.UNAUTHORIZED);
            }
        } else {
            return new ResponseEntity<>("Improper id provided", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping(value = "/v1/user/self")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Object> getUserInfo(@RequestParam(required = false) Map<String, String> params, @RequestBody(required = false) User user1) {
        try {
            logger.info("Logging INFO with user controller get method");
            if (!params.isEmpty() && user1 != null) {
                // If payload is present, returning HTTP 400 Bad Request
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .header("Cache-Control", "no-cache")
                        .build();
            }

            String userEmail = SecurityContextHolder.getContext().getAuthentication().getName();
            User infoUser = userService.getUserByEmail(userEmail);

            if(infoUser.getStatus().equals("Expired")) {
                return new ResponseEntity<>("User verification link expired", HttpStatus.BAD_REQUEST);
            } else if (infoUser.getStatus().equals("Created")) {
                return new ResponseEntity<>("User is not verified", HttpStatus.BAD_REQUEST);
            }

            UserInfoDTO user = infoUser.toUserInfoDTO();
            return new ResponseEntity<>(user, HttpStatus.OK);
        } catch (Exception e) {
            e.fillInStackTrace();
            System.out.println("Error has occured" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("Cache-Control", "no-cache")
                    .build();
        }
    }

    @RequestMapping(value = "/v1/user", method = {RequestMethod.GET, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.HEAD, RequestMethod.PATCH, RequestMethod.TRACE, RequestMethod.OPTIONS})
    public ResponseEntity<Object> handleMethodNotAllowed() {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .header("Cache-Control", "no-cache")
                .build();
    }

    @RequestMapping(value = "/v1/user/self", method = {RequestMethod.POST, RequestMethod.DELETE, RequestMethod.HEAD, RequestMethod.PATCH, RequestMethod.TRACE, RequestMethod.OPTIONS})
    public ResponseEntity<Object> handleMethodsNotAllowed() {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .header("Cache-Control", "no-cache")
                .build();
    }

    private void publishWithErrorHandlerExample(String projectId, String topicId, String email, String id)
            throws IOException, InterruptedException {
        TopicName topicName = TopicName.of(projectId, topicId);
        Publisher publisher = null;

        try {
            // Create a publisher instance with default settings bound to the topic
            publisher = Publisher.newBuilder(topicName).build();

            // Create a JSON object with email and id
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("email", email);
            jsonObject.addProperty("id", id);
            String message = jsonObject.toString();

//            for (final String message : messages) {
                ByteString data = ByteString.copyFromUtf8(message);
                PubsubMessage pubsubMessage = PubsubMessage.newBuilder().setData(data).build();

                // Once published, returns a server-assigned message id (unique within the topic)
                ApiFuture<String> future = publisher.publish(pubsubMessage);

                // Add an asynchronous callback to handle success / failure
                ApiFutures.addCallback(
                        future,
                        new ApiFutureCallback<String>() {

                            @Override
                            public void onFailure(Throwable throwable) {
                                if (throwable instanceof ApiException) {
                                    ApiException apiException = ((ApiException) throwable);
                                    // details on the API exception
                                    System.out.println(apiException.getStatusCode().getCode());
                                    System.out.println(apiException.isRetryable());
                                }
                                System.out.println("Error publishing message : " + message);
                            }

                            @Override
                            public void onSuccess(String messageId) {
                                // Once published, returns server-assigned message ids (unique within the topic)
                                System.out.println("Published message ID: " + messageId);
                            }
                        },
                        MoreExecutors.directExecutor());
        } finally {
            if (publisher != null) {
                // When finished with the publisher, shutdown to free up resources.
                publisher.shutdown();
                publisher.awaitTermination(1, TimeUnit.MINUTES);
            }
        }
    }
}