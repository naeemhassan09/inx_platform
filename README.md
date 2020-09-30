# inx_platform
# kafka-connect-docker
Following this quickstart guide: https://docs.confluent.io/current/installation/docker/docs/quickstart.html

For the confluent, using these images:
https://github.com/confluentinc/cp-docker-images

For vanilla Kafka, usign these images:
https://github.com/1ambda/docker-kafka-connect


## Start

These commands are using the names and port numbers based on the docker-compose.yml file provided.

#### Spin up Kafka, Zookeeper and Connect

On Mac,Windows and Linux, you should just be able to run a `docker-compose -f docker-compose.yml up`


(either way, add `-d` if you want to run in detached mode. You can use `docker logs <containerName>` to see the logs later if needed)

#### To see the running docker containers
`docker ps`

#### To see the pulled images

`docker images`

#### List all containers (only IDs)

`docker ps -aq`

#### Stop all running containers

`docker stop $(docker ps -aq)`

#### Remove all containers

`docker rm $(docker ps -aq)`

#### Remove all images

`docker rmi $(docker images -q)`




## Kafka

NB: You can run all of the following commands through opening a bash window for the container instead of using `docker exec` every time:

- Open a bash for the kafka container: `docker exec -it kafka bash`
- Run all the commands without `docker exec kafka`
- Type `exit` to leave the bash window

#### Create topic
`docker exec kafka kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181`

#### Check topic is created
`docker exec kafka kafka-topics --describe --topic foo --zookeeper zookeeper:2181`

#### Send msg to topic using built-in console producer
`docker exec kafka bash -c "seq 42 | kafka-console-producer --request-required-acks 1 --broker-list localhost:9092 --topic foo && echo 'Produced 42 messages.'"`

#### Read back the msg from the topic using the built-in console consumer
`docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic foo --from-beginning --max-messages 42`

## Kafka Connect

NB: You can run all of the following commands through opening a bash window for the container instead of using `docker exec` every time:

- Open a bash for the connect container: `docker exec -it connect bash`
- Run all the commands without `docker exec connect`
- Type `exit` to leave the bash window

#### View topics that already exist
`docker exec connect kafka-topics --describe --zookeeper zookeeper:2181`

(You should see the offset, config, and status topics that we created as part of the docker compose)

#### Create a topic for storing data that we'll send to kafka
`docker exec connect kafka-topics --create --topic quickstart-data --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181`

#### Create a directory for our input and output data files to live
`docker exec connect mkdir -p /tmp/quickstart/file`

#### Create a file with dummy data for our FileSource Connector to read from
The quickstart tutorial says to use:
`docker exec connect bash -c 'seq 1000 > /tmp/quickstart/file/input.txt'`

#### Note about curl commands
For all curl commands, you can use Postman (or something similar) as the connect REST API is available on localhost:8083 e.g.:

GET `http://localhost:8083/connectors/quickstart-file-source/status`

I actually preferred this method as it was easier to follow along and see responses.

#### Create a FileSource Connector to read a file from disk
`docker exec connect curl -s -X POST -H "Content-Type: application/json" --data '{"name": "quickstart-file-source", "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSourceConnector", "tasks.max":"1", "topic":"quickstart-data", "file": "/tmp/quickstart/file/input.txt"}}' http://connect:8083/connectors`

#### Check status of source connector
`docker exec connect curl -s -X GET http://connect:8083/connectors/quickstart-file-source/status`

#### Read 10 records from the quickstart-data topic (using built in console consumer)
`docker exec connect kafka-console-consumer --bootstrap-server kafka:9092 --topic quickstart-data --from-beginning --max-messages 10`

#### Create a FileSink Connector
`docker exec connect curl -X POST -H "Content-Type: application/json" --data '{"name": "quickstart-file-sink", "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector", "tasks.max":"1", "topics":"quickstart-data", "file": "/tmp/quickstart/file/output.txt"}}' http://connect:8083/connectors`

#### Check status of sink connector
`docker exec connect curl -s -X GET http://connect:8083/connectors/quickstart-file-sink/status`

#### Check that the connector worked by viewing the content of the output file
`docker exec connect cat /tmp/quickstart/file/output.txt`

## Adding a plugin [Example: twitter source]
Example of adding a connector to your Kafka Connect cluster.

Follow the steps in this repository to get the .jar file:

https://github.com/Eneco/kafka-connect-twitter

#### Copy jar file into the Kafka Connect cluster

`docker cp C:\kafka-connect-jars\kafka-connect-twitter-0.1-jar-with-dependencies.jar connect:/usr/share/java/`

You should be able to see that it has been copied over if you run:

`docker exec connect ls /usr/share/java`

Restart the Kafka Connect container so that the worker picks up the new jar (`ctrl+C` then `docker-compose up` again).

You can check that your new plugin/connector jar is ready to use by checking available plugins:

`docker exec connect curl -s -X GET http://connect:8083/connector-plugins`