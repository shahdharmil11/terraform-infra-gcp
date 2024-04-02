package com.cloudcourse.assignment01.model;

import com.cloudcourse.assignment01.dao.UserInfoDTO;

import javax.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Calendar;

@Entity
@Table(name = "USERS")
@SequenceGenerator(name = "UserSeq", sequenceName = "USER_SEQ")
public class User implements Serializable {

    @Id
    @GeneratedValue(generator = "UserSeq")
    private Long id;

    @Column(name="first_name")
    private String first_name;

    @Column(name="account_created")
    private LocalDateTime account_created;

    @Column(name="account_updated")
    private LocalDateTime account_updated;

    @Column(name="last_name")
    private String last_name;

    @Column(name="password")
    private String password;

    @Column(name="email")
    private String email;

    @Column(name="status", nullable = false)
    private String status;

    @Column(name="expiry_time")
    private LocalDateTime verification_expiry_time;

    @PrePersist
    protected void onCreate() {
        this.account_created = LocalDateTime.now();
        this.account_updated = LocalDateTime.now();
        this.status="Created";
        this.verification_expiry_time = LocalDateTime.now().plusMinutes(2);
    }

    @PreUpdate
    protected void onUpdate() {
        this.account_updated = LocalDateTime.now();
    }

    public User(String first_name, LocalDateTime account_created, LocalDateTime account_updated, String last_name, String password, String email, String status, LocalDateTime verification_expiry_time) {
        this.first_name = first_name;
        this.account_created = account_created;
        this.account_updated = account_updated;
        this.last_name = last_name;
        this.password = password;
        this.email = email;
        this.status = status;
        this.verification_expiry_time = verification_expiry_time;
    }

    public User(String first_name, String last_name, String password, String email, LocalDateTime account_created, LocalDateTime account_updated) {
        this.first_name = first_name;
        this.account_created = account_created;
        this.account_updated = account_updated;
        this.last_name = last_name;
        this.password = password;
        this.email = email;
    }

    public UserInfoDTO toUserInfoDTO() {
        UserInfoDTO userInfoDTO = new UserInfoDTO();
        userInfoDTO.setFirstName(this.getFirst_name());
        userInfoDTO.setLastName(this.getLast_name());
        userInfoDTO.setEmail(this.getEmail());
        userInfoDTO.setAccount_created(this.getAccount_created());
        userInfoDTO.setAccount_updated(this.getAccount_updated());
        userInfoDTO.setId(this.getId());
        return userInfoDTO;
    }

    protected User() {}

    public Long getId() {
        return id;
    }

    public String getFirst_name() {
        return first_name;
    }

    public void setFirst_name(String firstName) {
        this.first_name = firstName;
    }

    public String getLast_name() {
        return last_name;
    }

    public void setLast_name(String lastName) {
        this.last_name = lastName;
    }

    public LocalDateTime getAccount_created() {
        return account_created;
    }

    public void setAccount_created(LocalDateTime accountCreatedDate) {
        this.account_created = accountCreatedDate;
    }

    public LocalDateTime getAccount_updated() {
        return account_updated;
    }

    public void setAccount_updated(LocalDateTime accountUpdatedDate) {
        this.account_updated = accountUpdatedDate;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPassword() {
        return password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return first_name + last_name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getVerification_expiry_time() {
        return verification_expiry_time;
    }

    public void setVerification_expiry_time(LocalDateTime verification_expiry_time) {
        this.verification_expiry_time = verification_expiry_time;
    }

}
