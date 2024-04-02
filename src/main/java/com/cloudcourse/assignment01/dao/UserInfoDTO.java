package com.cloudcourse.assignment01.dao;

import java.time.LocalDateTime;

public class UserInfoDTO {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private LocalDateTime account_created;
    private LocalDateTime account_updated;

    public UserInfoDTO(Long id, String firstName, String lastName, String email, LocalDateTime account_created, LocalDateTime account_updated) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.account_created = account_created;
        this.account_updated = account_updated;
    }

    public UserInfoDTO() {
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getAccount_created() {
        return account_created;
    }

    public void setAccount_created(LocalDateTime account_created) {
        this.account_created = account_created;
    }

    public LocalDateTime getAccount_updated() {
        return account_updated;
    }

    public void setAccount_updated(LocalDateTime account_updated) {
        this.account_updated = account_updated;
    }

    @Override
    public String toString() {
        return "UserInfoDTO{" +
                "id=" + id +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", email='" + email + '\'' +
                ", accountCreated=" + account_created +
                ", accountUpdated=" + account_updated +
                '}';
    }
}
