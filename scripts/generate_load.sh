#!/bin/bash

URL="http://<EC2_IP>:8000"

echo "Generating traffic..."

while true; do
	curl -s $URL > /dev/null
done
