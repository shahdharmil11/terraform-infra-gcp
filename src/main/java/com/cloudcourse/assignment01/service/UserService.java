package com.cloudcourse.assignment01.service;

import com.cloudcourse.assignment01.dao.EmailTrackerRepository;
import com.cloudcourse.assignment01.dao.UserDao;
import com.cloudcourse.assignment01.model.EmailTracker;
import com.cloudcourse.assignment01.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Calendar;
import java.util.Optional;
import java.util.UUID;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@Service
public class UserService {

    @Autowired
    private final UserDao userRepository;

    @Autowired
    private final EmailTrackerRepository emailTrackerRepository;

    private static final Logger logger = LogManager.getLogger(UserService.class);

    private final BCryptPasswordEncoder passwordEncoder;

    @Autowired
    public UserService(UserDao userRepository, EmailTrackerRepository emailTrackerRepository, @Qualifier("bcryptPasswordEncoder") BCryptPasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.emailTrackerRepository = emailTrackerRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public static Calendar convertLocalDateTimeToCalendar(LocalDateTime localDateTime) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(localDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
        return calendar;
    }

    public User createUser(User user) {

        logger.info("Inside create user method" + user.getEmail());

        if (isInvalidUser(user)) {
            throw new IllegalArgumentException("Email, first name, last name, and password are required.");
        }

        if (!isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email is invalid.");
        }

        LocalDateTime currentDateTime = LocalDateTime.now();
//        Calendar calendar = convertLocalDateTimeToCalendar(currentDateTime);

        // Set account_created to the current time
        user.setStatus("Created");
        user.setAccount_created(currentDateTime);
        user.setAccount_updated(currentDateTime);
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    private boolean isValidEmail(String email) {
        // You can use a regular expression or a library for more robust email validation
        // Here's a simple example using a basic regex:
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email.matches(emailRegex);
    }

    private boolean isInvalidUser(User user) {
        return user.getFirst_name() == null || user.getFirst_name().isEmpty() ||
                user.getLast_name() == null || user.getLast_name().isEmpty() ||
                user.getPassword() == null || user.getPassword().isEmpty();
    }

    public User updateUser(User existingUser, User updatedUser) {
        // Update only allowed fields

        if(updatedUser.getId()!=null || updatedUser.getAccount_created()!=null || updatedUser.getAccount_updated()!=null || updatedUser.getEmail()!=null) {
            throw new IllegalArgumentException("Extra details are sent");
        }
//        if (!isValidEmail(updatedUser.getEmail())) {
//            throw new IllegalArgumentException("Email is invalid.");
//        }
        if (isInvalidUser(updatedUser)) {
            throw new IllegalArgumentException("First name, last name, and password are required.");
        }

        if(updatedUser.getFirst_name().isEmpty() && updatedUser.getLast_name().isEmpty() && updatedUser.getPassword().isEmpty()) {
            throw new HttpMessageNotReadableException("no content");
        }

        if(updatedUser.getFirst_name()!=null) {
            existingUser.setFirst_name(updatedUser.getFirst_name());
        }
        if(updatedUser.getLast_name()!=null) {
            existingUser.setLast_name(updatedUser.getLast_name());
        }

        LocalDateTime currentDateTime = LocalDateTime.now();
//        Calendar calendar = convertLocalDateTimeToCalendar(currentDateTime);

        // Update account_updated to the current time
        existingUser.setAccount_updated(currentDateTime);

        // Update password if provided
        if (updatedUser.getPassword() != null) {
            existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
        }

        return userRepository.save(existingUser);
    }

//    public EmailTracker emailTrackerDetails(String id) {
//        boolean tracker = Optional.of(emailTrackerRepository.findById(UUID.fromString(id))).isPresent();
//    }

    public boolean verifyUser(User existingUser) {

        LocalDateTime currentDateTime = LocalDateTime.now();
        Calendar calendar = convertLocalDateTimeToCalendar(currentDateTime);

        // Check if the verification link has expired
        LocalDateTime expirationTime = existingUser.getVerification_expiry_time();
        LocalDateTime currentTime = LocalDateTime.now();
        if (expirationTime == null || currentTime.isAfter(expirationTime)) {
            existingUser.setStatus("Expired");
            userRepository.save(existingUser);
            return false;
        }

        existingUser.setStatus("Verified");
        userRepository.save(existingUser);
        return true;
    }

    public User getUserByID(Long id) {
        logger.info("Inside get user method" + id);
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    public User getUserByEmail(String email) {
        logger.info("Inside create user method" + email);
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }
}
