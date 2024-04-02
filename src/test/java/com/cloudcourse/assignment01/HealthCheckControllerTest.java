//package com.cloudcourse.assignment01;
//
//import com.cloudcourse.assignment01.controller.HealthCheckController;
//import com.cloudcourse.assignment01.service.DatabaseService;
//import com.cloudcourse.assignment01.service.HealthCheckService;
//import org.json.simple.JSONObject;
//import org.junit.Test;
//import org.junit.runner.RunWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.MockitoJUnitRunner;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//
//import java.util.Optional;
//
//import static org.junit.Assert.assertEquals;
//import static org.mockito.Mockito.when;
//
//@RunWith(MockitoJUnitRunner.class)
//public class HealthCheckControllerTest {
//
//    @Mock
//    private DatabaseService databaseService;
//
//    @Mock
//    private HealthCheckService healthCheckService;
//
//    @InjectMocks
//    private HealthCheckController healthCheckController;
//
//    @Test
//    public void testDisconnectedDatabase() {
//        // Mock databaseService to simulate a disconnected database
//        when(healthCheckService.isDatabaseConnected()).thenReturn(false);
//
//        // Perform the health check
//        ResponseEntity<Object> responseEntity = healthCheckController.healthCheck(Optional.empty());
//
//        // Verify that the response is HTTP 503 Service Unavailable
//        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, responseEntity.getStatusCode());
//    }
//
//    @Test
//    public void testConnectedDatabaseWithPayload() {
//        // Mock databaseService to simulate a connected database
////        when(healthCheckService.isDatabaseConnected()).thenReturn(true);
//
//        JSONObject obj=new JSONObject();
//        obj.put("name","sonoo");
//
//        // Perform the health check
//        ResponseEntity<Object> responseEntity = healthCheckController.healthCheck(obj);
//
//        // Verify that the response is HTTP 200 OK
//        assertEquals(HttpStatus.BAD_REQUEST, responseEntity.getStatusCode());
//    }
//
//    @Test
//    public void testConnectedDatabase() {
//        // Mock databaseService to simulate a connected database
//        when(healthCheckService.isDatabaseConnected()).thenReturn(true);
//
//            JSONObject obj=new JSONObject();
//            obj.put("name","sonoo");
//
//        // Perform the health check
//        ResponseEntity<Object> responseEntity = healthCheckController.healthCheck(Optional.empty());
//
//        // Verify that the response is HTTP 200 OK
//        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
//    }
//
//    @Test
//    public void testConnectedDatabase_Exception() {
//        // Mock databaseService to simulate a connected database
//        when(healthCheckService.isDatabaseConnected()).thenThrow(RuntimeException.class);
//
//        JSONObject obj=new JSONObject();
//        obj.put("name","sonoo");
//
//        // Perform the health check
//        ResponseEntity<Object> responseEntity = healthCheckController.healthCheck(Optional.empty());
//
//        // Verify that the response is HTTP 200 OK
//        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, responseEntity.getStatusCode());
//    }
//
//}
