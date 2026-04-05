#!/bin/bash

URL="http://localhost:8000"

echo "Generating traffic..."

while true; do
	curl -s $URL > /dev/null
done
