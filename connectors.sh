#!/bin/bash

# Kafka rest proxy REST API URL
CONNECT_URL="http://localhost:8083/connectors"

# JDBC Sink Connector Configuration JSON file
CONFIG_FILE="./config/connect-jdbc-sink.json"

# Send connector configuration to Kafka Connect
curl -v POST -H "Content-Type: application/json" --data "@$CONFIG_FILE" $CONNECT_URL | jq