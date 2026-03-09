#!/bin/bash
#
# Build the IG using Docker (recommended) or local Java.
#
# Docker build (requires Docker):
#   ./_genonce.sh docker
#
# Local build (requires Java 17+, Jekyll):
#   ./_genonce.sh
#

publisher_jar=publisher.jar
input_cache_path=./input-cache/

# Run SUSHI first to generate the ImplementationGuide resource
if command -v sushi &> /dev/null; then
	echo "Running SUSHI..."
	sushi .
else
	echo "SUSHI not found. Install with: npm install -g fsh-sushi"
	echo "Continuing without SUSHI (requires pre-generated fsh-generated/)..."
fi

echo Checking internet connection...
curl -sSf tx.fhir.org > /dev/null

if [ $? -eq 0 ]; then
	echo "Online"
	txoption=""
else
	echo "Offline"
	txoption="-tx n/a"
fi

echo "$txoption"

if [ "$1" = "docker" ]; then
	echo "Building with Docker..."
	docker run --rm --user root --entrypoint bash \
		-v "$(pwd):/ig" \
		-v "$HOME/.fhir/packages:/root/.fhir/packages" \
		-w /ig \
		hl7fhir/ig-publisher-base:latest \
		-c "java -Xmx4g -jar input-cache/publisher.jar -ig . $txoption"
else
	export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Dfile.encoding=UTF-8"

	publisher=$input_cache_path/$publisher_jar
	if test -f "$publisher"; then
		java -jar $publisher -ig . $txoption $*
	else
		publisher=../$publisher_jar
		if test -f "$publisher"; then
			java -jar $publisher -ig . $txoption $*
		else
			echo IG Publisher NOT FOUND in input-cache or parent folder.  Please run _updatePublisher.  Aborting...
		fi
	fi
fi
