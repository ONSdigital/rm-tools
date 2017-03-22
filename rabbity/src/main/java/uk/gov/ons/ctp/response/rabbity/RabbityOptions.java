package uk.gov.ons.ctp.response.rabbity;

import com.google.devtools.common.options.Option;
import com.google.devtools.common.options.OptionsBase;

public class RabbityOptions extends OptionsBase {

  @Option(
      name = "help",
      abbrev = 'h',
      help = "Prints usage info.",
      defaultValue = "true"
    )
  public boolean help;

  @Option(
      name = "queue",
      abbrev = 'q',
      help = "The JMS/AMQP queue name to send the message to",
      category = "startup",
      defaultValue = ""
  )
  public String queueName;

  @Option(
    name = "dir",
    abbrev = 'd',
    help = "Name of directory from which to find xml message files - these will be deleted after use!",
    category = "startup",
    defaultValue = ""
    )
    public String messageDir;

  @Option(
    name = "rabbithost",
    abbrev = 'r',
    help = "The hostname for the rabbitmq broker to send messages to",
    category = "startup",
    defaultValue = ""
    )
    public String rabbitHost;

  @Option(
    name = "port",
    abbrev = 'p',
    help = "The port for the rabbitmq broker to send messages to",
    category = "startup",
    defaultValue = ""
    )
    public String rabbitPort;

  @Option(
    name = "user",
    abbrev = 'u',
    help = "The username for the rabbitmq broker to send messages to",
    category = "startup",
    defaultValue = ""
    )
    public String rabbitUser;

  @Option(
    name = "password",
    abbrev = 'w',
    help = "The password for the rabbitmq broker to send messages to",
    category = "startup",
    defaultValue = ""
    )
    public String rabbitPassword;
}
