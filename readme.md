# Kafka JDBC SQL connector POC

Eventsource pattern used to form a tote pool. With a JDBC stream connector to demostrate how to auto create and insert data sourced up stream from Confluence Kafka Schema Registry. So we create a first class citizen and method to introduce data consistency. This is to build strong information architecture into the design of your data engineering. It removes the need for any integration layer with data mapping.  

![schema registry across connectors and database](/Schema_registry.png)

Please refer to this repo for explaination of the other details; [Tote pool poc] https://github.com/elliotrock/poc-kafka-totes-pool


### Considerations;
* Build in Docker so you have to consider the volumes and network is within that container
* The JDBC driver for Postgres is attached into the docker image `postgres-docker` for postgres to be able to communicate with the kafka connector.
* The plugins and drivers are local to this repo for Confluent Kafka and JDBC. Even if the pattern Confluent recommends is to use their local hub. A major consideration not to do this was for transportability. 
* Only 2 stream are sinked which is configurated in `connect-jdbc-sink.json`

 `"topics": "tote_win_bets,tote_win_bet_race_runners_odds"`

 If you want to do a regex on the other tables or streams, so any additions are auto created, use below instead of  `"topics"`

 `// "topics.regex": "tote_.*",` 
 * The KsqlDB streams and tables in `statements.sql` show an example of two streams being created as topics, which is needed for them to be stored on the Schema Register, using `kafka_topic`. This is needed for various connectors to work. 
 * As this is event driven you need to consider eventual consistence, as tables and streams are trigger by each other. The order of events cannot be sequencial, and nor should you force a design to try to make it. 
 
 An Event Sourcing pattern is very good at huge transistions, in this case the transistions show an addition or subtraction. I have used 0 amounts to show a way of flushing the tables and streams to get a state of eventual consistence.   

### Prerequisites
* Docker desktop, best way to run Docker locally. The install bash has a brew for docker but you will still need the Docker for Desktop for the engine: https://www.docker.com/products/docker-desktop/


### Install and run
1. `bash install.sh`
To install any missing dependencies. Including makefile.

2. `make start`
To run the docker containers.

3. `make build`
To build the streams and tables, then the JDBC connector configuration. The makefile has the permissions added.

4. `make play`
To POST the bets to the rest-proxy. There are two batches of bets here to demostrate how kafka works when it batches a chunk of events into a stream.

6. In your browser Vview the postgres database via [adminer]  http://localhost:8080/  System: `PostgeSQL` Password: `example` User: `postgres`

5. Optional  `make cli`
To start the ksqlDB CLI. Open a new terminal window for this. 

Once you have build the streams and tables a nice way of running a demo is to run a pull query in `ksqldb-cli` on the final stream `tote_win_bet_race_runners_odds` like;

`SELECT * FROM tote_win_bet_race_runners_odds WHERE race_id = 0 EMIT CHANGES` 

This will continously print to console changes to that stream.

`SELECT * FROM tote_win_bet_race_runners_odds WHERE race_id = 0`

Will display that stream.


**Problem Shooting:** Run `bash utilities/schema_query.sh` to get the schema_value id and edit the above bash scripts.

Sending bets using the REST Proxy. The bash script below requires the `value_schema_id`. If you start from scratch it should be `1`.  `bash post_bets.sh`,  `bash post_bets_large.sh`


### Kill, prune and clear the containers 

`make down`
To kill the running docker

`make prune`
To remove any instances and volumes, good for clearing streams or if you have made structural changes during development.


### Useful queries

`SHOW STREAMS;`
`SHOW TABLES;` | `LIST TABLE;`
`SHOW queries;`
`DESCRIBE table | stream;`
Details of that steam or table, including type of data.

`PRINT 'topic' FROM BEGINNING INTERVAL 1;`
A way of seeing the output.

`DROP TABLE table_name;` 
`DROP STREAM table_name;` 
You will need to terminate any querys creating the table first;

`TERMINATE query_id;` 

