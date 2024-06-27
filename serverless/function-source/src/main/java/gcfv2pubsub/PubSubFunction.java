  package gcfv2pubsub;

  import com.google.cloud.functions.CloudEventsFunction;
  import com.google.events.cloud.pubsub.v1.Message;
  import com.google.events.cloud.pubsub.v1.MessagePublishedData;
  import com.google.gson.Gson;
  import com.google.gson.JsonObject;
  import io.cloudevents.CloudEvent;
  import org.apache.http.HttpResponse;
  import org.apache.http.client.HttpClient;
  import org.apache.http.client.methods.HttpPost;
  import org.apache.http.entity.ContentType;
  import org.apache.http.entity.StringEntity;
  import org.apache.http.impl.client.HttpClients;
  import java.io.IOException;
  import java.net.URLEncoder;
  import java.nio.charset.StandardCharsets;
  import java.sql.*;
  import java.time.LocalDateTime;
  import java.time.format.DateTimeFormatter;
  import java.util.Base64;
  import java.util.logging.Logger;


  public class PubSubFunction implements CloudEventsFunction {
    private static final Logger logger = Logger.getLogger(PubSubFunction.class.getName());

    @Override
    public void accept(CloudEvent event) throws SQLException {

      String cloudEventData = new String(event.getData().toBytes());

      Gson gson = new Gson();
      MessagePublishedData data = gson.fromJson(cloudEventData, MessagePublishedData.class);


      if (data != null && data.getMessage() != null) {

        Message message = data.getMessage();

        String encodedData = message.getData();
        String decodedData = new String(Base64.getDecoder().decode(encodedData));

        logger.info("Pub/Sub message: " + decodedData);

        JsonObject jsonPayload=gson.fromJson(decodedData,JsonObject.class);

        String email=jsonPayload.get("UserName").getAsString();

        String ID=jsonPayload.get("UserId").getAsString();

        String verificationLink = generateVerificationLink(email,ID);

        try {
          sendVerificationEmail(email, verificationLink,ID);
        } catch (IOException e) {
          logger.severe("Error sending verification email: " + e.getMessage());
        }
      } else {
        logger.info("Invalid or null data received from Pub/Sub.");
      }
    }

    private String generateVerificationLink(String email, String ID) throws SQLException {

      LocalDateTime currentTime = LocalDateTime.now();
      LocalDateTime ExpirationTime=LocalDateTime.now().plusMinutes(2);

      String verificationLink = System.getenv("WEBAPP_URL") + "?email=" + email + "&id=" + ID ;
      System.out.println("Verification Link: " + verificationLink);

      saveToDatabase(email, ExpirationTime,ID,currentTime);
      return URLEncoder.encode(verificationLink, StandardCharsets.UTF_8);

    }

    private void saveToDatabase(String email, LocalDateTime expirationTime, String id,LocalDateTime currentTime) {
      String dbUrl = "jdbc:postgresql://" + System.getenv("SQL_PRIVATE_IP") + ":5432/" + System.getenv("DB_NAME");
      String dbUsername = System.getenv("SQL_USERNAME");
      String dbPassword = System.getenv("SQL_PASSWORD");
      logger.info("dbUrl: " + dbUrl);
      logger.info("dbUsername: " + dbUsername);
      logger.info("dbPassword: " + dbPassword);
      try {

        Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
        logger.info("Connected to the database.");

        String insertSql = "INSERT INTO email_tracker (link_expiration_time, link_send_time, id, email) VALUES (?, ?, ?,?)";

        PreparedStatement preparedStatement = conn.prepareStatement(insertSql);

        preparedStatement.setTimestamp(1, Timestamp.valueOf(expirationTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSSSS"))));
        preparedStatement.setTimestamp(2, Timestamp.valueOf(currentTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSSSS"))));
        preparedStatement.setString(3, id);
        preparedStatement.setString(4, email);

        int rowsAffected = preparedStatement.executeUpdate();
        logger.info("Rows affected by insertion: " + rowsAffected);


        preparedStatement.close();
        conn.close();

      } catch (SQLException e) {
        logger.info("Error inserting data into the database: " + e.getMessage());
      }

    }

    private void sendVerificationEmail(String recipientEmail, String verificationLink, String ID) throws IOException {

      final String apiKey = System.getenv("MAILGUN_API_KEY");
      final String domain = "gcp-infra-dharmil.me";

      HttpClient httpClient = HttpClients.createDefault();

      HttpPost httpPost = new HttpPost("https://api.mailgun.net/v3/" + domain + "/messages");
      String emailContent = "Hello, we're excited to have you here, \n Click the link below to verify your email address:\n" + verificationLink + "\n\nThis link will expire in 2 minutes.";
      System.out.println("Email Content:" + emailContent);

      httpPost.setHeader("Authorization", "Basic " + Base64.getEncoder().encodeToString(("api:" + apiKey).getBytes()));
      httpPost.setHeader("Content-Type", "application/x-www-form-urlencoded");

      StringEntity entity = new StringEntity(
              "from=New User Verification Mail <noreply@" + domain + ">&" +
                      "to=" + recipientEmail + "&" +
                      "subject=Verify Your Email Address&" +
                      "text=" + emailContent,
              ContentType.APPLICATION_FORM_URLENCODED);

      httpPost.setEntity(entity);
      HttpResponse response = httpClient.execute(httpPost);

      
      if (response != null) {
        logger.info("Mailgun API response: " + response.getStatusLine().getStatusCode());
      } else {
        logger.info("Mailgun API response: Response is null.");
      }
    }
  }