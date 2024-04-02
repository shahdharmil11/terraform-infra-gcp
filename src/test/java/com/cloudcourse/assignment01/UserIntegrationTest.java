//package com.cloudcourse.assignment01;
//
//import com.cloudcourse.assignment01.model.User;
//import io.restassured.RestAssured;
//import io.restassured.http.ContentType;
//import org.junit.jupiter.api.MethodOrderer;
//import org.junit.jupiter.api.Order;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.TestMethodOrder;
//import org.springframework.boot.test.context.SpringBootTest;
//import org.springframework.boot.web.server.LocalServerPort;
//
//import static io.restassured.RestAssured.given;
//
//@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
//@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
//class UserIntegrationTest {
//
//    @LocalServerPort
//    private int port;
//
//    @Test
//    @Order(2)
//    public void whenUpdateUserWithValidDataAndBasicAuth_thenReturns200() {
//        // Set the base URI for the API
//        RestAssured.baseURI = "http://localhost";
//        RestAssured.port = port;
//
//        // Set the username and password for basic authentication
//        String username = "abcd.doe@example.com";
//        String password = "admin";
//
//        // Create a new user object with updated data
//        User user = new User("John1", "Doe1", "admin", null, null, null);
//
//        // Send a PUT request to the /v1/user/self endpoint with basic authentication and the updated user object as the request body
//        given()
//                .auth().basic(username, password)
//                .contentType(ContentType.JSON)
//                .body(user)
//                .when()
//                .put("/v1/user/self")
//                .then()
//                .assertThat()
//                .statusCode(200); // Verify that the response status code is 200 (OK)
//    }
//
//    @Test
//    @Order(3)
//    public void whenUpdateUserWithInvalidData_thenReturns400() {
//        // Set the base URI for the API
//        RestAssured.baseURI = "http://localhost";
//        RestAssured.port = port;
//
//        // Set the username and password for basic authentication
//        String username = "abcd.doe@example.com";
//        String password = "admin";
//
//        // Create a new user object with invalid data
//        User invalidUser = new User("John", "Doe", "admin", "11", null, null);
//        // Assuming the email is required and this is invalid because it's missing
//
//        // Send a PUT request to the /v1/user/self endpoint with the invalid user object as the request body
//        given()
//                .auth().basic(username, password)
//                .contentType(ContentType.JSON)
//                .body(invalidUser)
//                .when()
//                .put("/v1/user/self")
//                .then()
//                .assertThat()
//                .statusCode(400); // Verify that the response status code is 400 (Bad Request)
//    }
//
//    @Test
//    @Order(1)
//    public void whenuserWithValidData_thenReturns201() {
//        // Set the base URI for the API
//        RestAssured.baseURI = "http://localhost";
//        RestAssured.port= port;
//
//        // Create a new user object with valid data
//        User user = new User("John", "Doe", "admin", "abcd.doe@example.com", null, null);
//
//        // Send a POST request to the /v1/user endpoint with the user object as the request body
//        given()
//                .contentType(ContentType.JSON)
//                .body(user)
//                .when()
//                .post("/v1/user")
//                .then()
//                .assertThat()
//                .statusCode(201); // Verify that the response status code is 201 (Created)
//    }
//
//}
