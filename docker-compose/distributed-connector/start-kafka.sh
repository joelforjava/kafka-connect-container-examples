#!/bin/bash -e

# connector start command here.
exec "/opt/kafka/bin/connect-distributed.sh" "/opt/kafka/config/connect-distributed.properties"
