
Rabbity is the ONS CTP command line tool for replaying xml messages into JMS/AMQP queues.
The messages being replayed are most likely to have come from the application 'dead letter logs'.

## To build
./mvnw clean install

## To run
Rabbity requires two command line arguments as shown by the --help :

  --dir [-d] (a string; default: "")
    Name of directory from which to find xml message files - these will be
    deleted after use!
  --queue [-q] (a string; default: "")
    The JMS/AMQP queue name to send the message to

All files ending with '.xml' in the dir will be read and sent to the nominated queue.
After successful reading and sending of a file, it will be renamed to avoid re-replay.
ie 

'message-01.xml'

becomes

'message-01.xml.done'


java -jar target/rabbity-9.34.0-SNAPSHOT.jar -d <your_directory_here> -q <your_queuename_here>


