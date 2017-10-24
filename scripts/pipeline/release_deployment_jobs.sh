#!/bin/bash
mkdir target
echo $SERVICE 
echo $VERSION | grep "SNAPSHOT"
if [ $? -eq 1 ]
then
        echo "Deploying $SERVICE to SIT"
	# Get release build from artifactory
	curl "$RELEASE_URL/$SERVICE/$VERSION/$SERVICE-$VERSION.$EXT" > target/${SERVICE}.$EXT
  	if [ $(wc -c <"target/${SERVICE}.$EXT") -lt 8000000 ]; then echo "No Jar available in artifactory, deploy failed.";exit 1;fi
else
 	echo "Can't deploy SNAPSHOT!"
    exit 1
fi
