.PHONY: cli 
cli:
	docker exec -it ksqldb-cli ksql http://ksqldb-server:8088	

.PHONY: play
play:
	chmod u+x play.sh
	bash play.sh

.PHONY: build
build:
	chmod u+x build.sh
	bash build.sh

.PHONY: connectors
connectors:
	chmod u+x connectors.sh
	bash connectors.sh

.PHONY: start
start: 
	# chmod o + r drivers/postresql-47.7.3.jar
	docker-compose up

.PHONY: stop
stop: 
	docker-compose stop

.PHONY: down
down: 
	docker-compose down

.PHONY: prune
prune: 
	docker container prune