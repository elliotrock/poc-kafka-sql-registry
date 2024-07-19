.PHONY: cli 
cli:
	docker exec -it ksqldb-cli ksql http://ksqldb-server:8088	

.PHONY: play
play:
	chmod u+x post_bets.sh
	chmod u+x post_bets_large.sh
	bash post_bets.sh
	@sleep 2
	bash post_bets_large.sh

.PHONY: build
build:
	chmod u+x build.sh
	bash build.sh
	chmod u+x connectors.sh
	bash connectors.sh

.PHONY: start
start: 
	docker compose up

.PHONY: stop
stop: 
	docker compose stop

.PHONY: down
down: 
	docker compose down

.PHONY: prune
prune: 
	docker container prune