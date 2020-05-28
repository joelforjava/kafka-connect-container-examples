# Quick Step by Step

## Starting the Source Connector

Quick steps to run this folder's content, required to open multiple terminals when needed.

-  Check out this repo. 

`git clone git@github.com:stockgeeks/docker-compose.git`

-  Navigate to `kafka-connect-crash-course` directory.

`cd docker-compose/kafka-connect-crash-course`

-  Build the docker images as the connect image is required to build to include connector standalone configurations, we 
could have used a map to provide the files but building it for now.

`docker-compose build`

-  Run the docker containers, it will run Zookeeper, Kafka and the Connector in background.

`docker-compose up -d`

- Check the docker container logs attaching a terminal window to tail/follow them.

`docker-compose logs -f`

- Check the docker images running

`watch docker-compose ps`

- When running the docker-compose in some environments the folder where we will create the file from where the connector
is reading might be created as root user, this is due to how docker-compose and docker are setup and images are built,
change the folder permissions to your current user, in a terminal if necessary: 

`sudo chown $USER: connect-input-file`

-  Run in a new terminal window a command line client attached to the connect destination topic and wait for messages 
for validation as this is a source connector.

`docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic simple-connect --from-beginning`

- A sample data file should already exist in `connect-input-file` but if it isn't there, create a folder connect-input-file in the same level as the docker-compose.yml file where inside the connector expects to find the file where it will read lines from and publish to kafka, enter this directory and create a file named `my-source-file.txt`.

`cd connect-input-file && touch my-source-file.txt`

- Open the file with your preferred text editor and add lines to it and notice that the lines are automatically read by
the connector and published to the kafka topic where we have attached our console client every time you save the file,
it relies in a new line / blank line at the end of the file, so make sure to add it in order for it to work properly.

## Starting the Sink Connector

A separate Dockerfile and Docker Compose file for the sink connector are provided in the `sink-connector` directory. Complete the following steps to get it up and running.

- Find the name of the name of the existing network being used by kafka

`docker network ls`

    NETWORK ID          NAME                                 DRIVER              SCOPE
    24eebf964a9e        bridge                               bridge              local
    05b054e54bae        docker_sonarnet                      bridge              local
    b93a229f4eb2        host                                 host                local
    3bd1a87e56e1        kafka-connect-crash-course_default   bridge              local
    6700c111a17f        none                                 null                local

- Initialize the containers for the (distributed) sink connector

`docker-compose up --no-start`

- Connect the sink connector's network to the existing kafka network (`kafka-connect-crash-course_default` above)

`docker network connect kafka-connect-crash-course_default connect-distributed` 

- Complete the startup of the sink connector

`docker-compose up`

- Query the Connect REST API to verify it is running

`curl http://localhost:18083/connectors`

- Convert `distributed-connector/connect-file-sink.properties` to JSON format. I've provided a version of this as `connect-file-sink.json`.

- Push this JSON file content to the REST API

`curl -XPUT -H "Content-Type: application/json"  --data "@/Volumes/Macintosh Data/dev/learn/kafka-connect/docker-compose/kafka-connect-distributed/config.json" http://localhost:18083/connectors/file-sink-connector/config | jq`

- If all goes well, you should see an output similar to below (thanks to `jq`)

    {
      "name": "file-sink-connector",
      "config": {
        "name": "file-sink-connector",
        "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
        "tasks.max": "1",
        "topics": "simple-connect",
        "file": "/tmp/my-output-file.txt",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
        "value.converter": "org.apache.kafka.connect.storage.StringConverter"
      },
      "tasks": [
        {
          "connector": "file-sink-connector",
          "task": 0
        }
      ],
      "type": "sink"
    }

- If data exists on the topic, then you should see data output to `distributed-connector/connect-output-file`.
