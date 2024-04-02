//package com.cloudcourse.assignment01;
//
//@Testcontainers
//public class UserServiceTest {
//
//    @Container
//    private static final PostgreSQLContainer<?> postgreSQLContainer = new PostgreSQLContainer<>("postgres:latest")
//            .withDatabaseName("testdb")
//            .withUsername("testuser")
//            .withPassword("testpassword");
//
//    @Autowired
//    private UserService userService;
//
//    @Test
//    public void testGetUserByEmail() {
//        // The database connection details will be provided by the Test Container
//
//        // Call the service method
//        User user = userService.getUserByEmail("test@example.com");
//
//        // Assert the result
//        assertNotNull(user);
//        assertEquals("Test", user.getFirstName());
//        assertEquals("User", user.getLastName());
//    }
//}
