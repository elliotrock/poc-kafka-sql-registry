#!/bin/bash

# Kafka rest proxy REST API URL
CONNECT_URL="http://localhost:8083/connectors"

# JDBC Sink Connector Configuration JSON file
CONNECTOR_NAME="jdbc-sink-connector"

# Send connector configuration to Kafka Connect
curl -X DELETE $CONNECT_URL/$CONNECTOR_NAME | jq