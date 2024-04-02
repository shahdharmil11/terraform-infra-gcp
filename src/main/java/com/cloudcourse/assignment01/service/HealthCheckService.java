package com.cloudcourse.assignment01.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

@Service
public class HealthCheckService {

    @Autowired
    private DataSource dataSource; // Autowire the DataSource for database connectivity

    public boolean isDatabaseConnected() {
        try (Connection connection = dataSource.getConnection()) {
            System.out.println("Connection is established");
            // If no exception is thrown, the database connection is successful
            return true;
        } catch (SQLException e) {
            // Log the exception or handle it as needed
            return false;
        }
    }
}

