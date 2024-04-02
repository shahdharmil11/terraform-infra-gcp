package com.cloudcourse.assignment01.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
//import lombok.AllArgsConstructor;
//import lombok.Builder;
//import lombok.Data;
//import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "email_tracker")
public class EmailTracker {

    @JsonProperty("email")
    @Column(nullable = false, unique = true, name = "email")
    private String email;

    @Id
    @Column(columnDefinition = "VARCHAR(255)")
    private UUID id;

    @Column(name = "link_expiration_time")
    private LocalDateTime link_expiration_time;

    @Column(name = "link_send_time")
    private LocalDateTime link_send_time;

    public EmailTracker(String email, LocalDateTime linkExpirationTime, LocalDateTime linkSendTime) {
        this.email = email;
        link_expiration_time = linkExpirationTime;
        link_send_time = linkSendTime;
    }

    public EmailTracker() {

    }
}
