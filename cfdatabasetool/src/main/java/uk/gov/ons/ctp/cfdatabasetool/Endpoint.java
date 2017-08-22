package uk.gov.ons.ctp.cfdatabasetool;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
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
  public ResponseEntity<String> runQuery(final @Valid @RequestBody String sql) throws SQLException {

    Properties props = new Properties();
    props.setProperty("user",uname);
    props.setProperty("password",passwd);

    Connection conn = DriverManager.getConnection(url, props);
    Statement stmt = null;
    StringBuilder output =  new StringBuilder();

    try {
      stmt = conn.createStatement();
      ResultSet rs = stmt.executeQuery(sql);
      int columns = rs.getMetaData().getColumnCount();
      for(int i = 1;i<columns;i++) {
        output.append(rs.getMetaData().getColumnName(i)).append(",");
      }
      output.append(rs.getMetaData().getColumnName(columns)).append("\n");
      while (rs.next()) {
        for(int i = 1;i<columns;i++) {
          output.append(rs.getArray(i)).append(",");
        }
        output.append(rs.getArray(columns)).append("\n");
      }
      rs.close();
    } catch (SQLException e) {
      System.out.println(e);
    } finally {
      if (stmt != null) {
        stmt.close();
      }
      if (conn != null) {
        conn.close();
      }
    }
    return ResponseEntity.created(URI.create("TODO")).body(output.toString());
  }

}
