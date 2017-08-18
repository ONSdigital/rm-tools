package uk.gov.ons.ctp.cfdatabasetool;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * Created by wardlk on 18/08/2017.
 */
@RestController
@RequestMapping(value = "/sql")
@Slf4j
public final class Endpoint {

  @Value("${spring.datasource.url}")
  private String url;

  @Value("${spring.datasource.username}")
  private String uname;

  @Value("${spring.datasource.password}")
  private String passwd;

  @RequestMapping(method = RequestMethod.POST, consumes = "text/plain")
  public void clearDatabase(final @Valid @RequestBody String sql) throws SQLException {

    Properties props = new Properties();
    props.setProperty("user",uname);
    props.setProperty("password",passwd);
    Connection conn = DriverManager.getConnection(url, props);
    Statement stmt = null;
    try {
      stmt = conn.createStatement();
      stmt.executeQuery(sql);
    } catch (SQLException e) {
      System.out.println(e);
    } finally {
      if (stmt != null) { stmt.close(); }
    }

  }

}
