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