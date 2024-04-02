package com.cloudcourse.assignment01.dao;

import java.util.UUID;

import com.cloudcourse.assignment01.model.EmailTracker;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmailTrackerRepository extends JpaRepository<EmailTracker, UUID> {
}

