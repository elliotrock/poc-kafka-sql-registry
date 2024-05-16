# Kafka JDBC SQL connector POC

Eventsource pattern used to form a tote pool. With a JDBC stream connector to demostrate how to auto create and insert data sourced up stream from Confluence Kafka Schema Registry. So we create a first class citizen and method to introduce data consistency. This is to build strong information architecture into the design of your data engineering.  

Please refer to this repo for explaination of the other details; [Tote pool poc] https://github.com/elliotrock/poc-kafka-totes-pool


### Considerations;
* Build in Docker so you have to consider the volumes and network is within that container
* The JDBC driver for Postgres is attached into the docker image `postgres-docker` for postgres to be able to communicate with the kafka connector.
* The plugins and drivers are local to this repo for Confluent Kafka and JDBC. Even if the pattern Confluent recommends is to use their local hub. A major consideration not to do this was for transportability. 
* I am only sinking 2 stream which is configurated in `connect-jdbc-sink.json`

 `"topics": "tote_win_bets,tote_win_bet_race_runners_odds"`

 If you want to do a regex on the other tables or streams, so any additions are auto created, use below instead of  `"topics"`

 `// "topics.regex": "tote_.*",` 

### Prerequisites
* Docker desktop, best way to run Docker locally. The install bash has a brew for docker but you will still need the Docker for Desktop for the engine: https://www.docker.com/products/docker-desktop/


### Install and run
1. `bash install.sh`
To install any missing dependencies. Including makefile.

2. `make start`
To run the docker containers.

3. `make build` | `bash build.sh`
To build the streams and tables, then the JDBC connector configuration. The makefile has the permissions added.

4. Optional  `make cli`
To start the ksqlDB CLI. Open a new terminal window for this. 

Once you have build the streams and tables a nice way of running a demo is to run a pull query in `ksqldb-cli` on the final stream `tote_win_bet_race_runners_odds` like;

`SELECT * FROM tote_win_bet_race_runners_odds WHERE race_id = 0 EMIT CHANGES;` 

This will continously print to console changes to that stream.

5. Sending bets using the REST Proxy. The bash script below requires the schema id. If you start from scratch it should be `1`. 

`bash post_bets.sh`
Use this to insert a couple of bets into `tote_win_bets`.

`bash post_bets_large.sh`
Use this to insert an array of bets into `tote_win_bets`.

6. View the postgres database via [adminer]  http://localhost:8080/

**Problem Shooting:** Run `bash utilities/schema_query.sh` to get the schema_value id and edit the above bash scripts.


### Kill, prune and clear the containers 

`make kill`
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

