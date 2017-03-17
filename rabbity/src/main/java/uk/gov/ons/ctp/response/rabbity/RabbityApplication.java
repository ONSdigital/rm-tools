package uk.gov.ons.ctp.response.rabbity;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Collections;

import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.Session;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.core.MessageCreator;
import org.springframework.scheduling.annotation.EnableScheduling;

import com.google.devtools.common.options.OptionsParser;
import com.rabbitmq.jms.admin.RMQConnectionFactory;

import lombok.extern.slf4j.Slf4j;

/**
 * This simple application reads two args from the command line, the directory
 * to read xml files from and the queue to send the file contents to. It sends
 * the file contents via the JmsTemplate over Rabbit AMQP, so messages sent can
 * be read by the ONS CTP apps using JMS over AMQP. This util may never be used,
 * but will enable the resending of messages sent to the dead letter log.
 * 
 */
@EnableAutoConfiguration
@EnableScheduling
@Configuration
@ComponentScan
@Slf4j
public class RabbityApplication {

  @Autowired
  JmsTemplate jmsTemplate;

  @Bean
  RMQConnectionFactory connectionFactory() {
    return new RMQConnectionFactory();
  }

  public static void main(String[] args) {
    SpringApplication.run(RabbityApplication.class, args);
  }

  @Bean
  public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
    return args -> {
      OptionsParser parser = OptionsParser.newOptionsParser(RabbityOptions.class);
      parser.parseAndExitUponError(args);
      RabbityOptions options = parser.getOptions(RabbityOptions.class);
      if (options.queueName.isEmpty() || options.messageDir.isEmpty()) {
        printUsage(parser);
        return;
      }
      connectionFactory().setHost(options.rabbitHost);
      File dir = new File(options.messageDir);
      File[] files = dir.listFiles((d, name) -> name.endsWith(".xml"));
      int count = 0;
      for (File file : files) {
        log.info("Processing file : {}", file.getName());
        try {
          String content = new String(Files.readAllBytes(Paths.get(file.getPath())));
          publishMessage(options.queueName, content);
          file.renameTo(new File(file.getPath() + ".done"));
          count++;
        } catch (IOException ioe) {
          log.warn("Could not read file '{}'", file.getName());
        }
      }
      log.info("Rabbity successfully processed {} xml message files", count);
    };
  }

  private void publishMessage(String queueName, String msgBody) {
    MessageCreator messageCreator = new MessageCreator() {
      @Override
      public Message createMessage(Session session) throws JMSException {
        return session.createObjectMessage(msgBody);
      }
    };
    jmsTemplate.send(queueName, messageCreator);
  }

  private void printUsage(OptionsParser parser) {
    System.out.println("Usage: java -jar rabbity.jar OPTIONS");
    System.out.println(parser.describeOptions(Collections.<String, String> emptyMap(),
        OptionsParser.HelpVerbosity.LONG));
  }

}
