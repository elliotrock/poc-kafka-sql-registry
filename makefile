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

.PHONY: start
start: 
	docker-compose up

.PHONY: stop
stop: 
	docker-compose stop

.PHONY: kill
kill: 
	docker-compose kill

.PHONY: prune
prune: 
	docker container prune