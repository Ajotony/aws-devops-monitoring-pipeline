#!/bin/bash

URL="http://<EC2_IP>:8000"

echo "Triggering errors..."

for i in {1..200}; do
	curl -s $URL > /dev/null
done
