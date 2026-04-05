#!/bin/bash

URL="http://localhost:8000"

echo "Triggering errors..."

for i in {1..200}; do
	curl -s $URL > /dev/null
done
