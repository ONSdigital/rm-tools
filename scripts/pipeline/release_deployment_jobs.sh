#!/bin/bash
mkdir target
echo $SERVICE 
echo $VERSION | grep "SNAPSHOT"
if [ $? -eq 1 ]
then
        echo "Deploying $SERVICE to SIT"
	curl "$RELEASE_URL/$SERVICE/$VERSION/$SERVICE-$VERSION.jar" > target/${SERVICE}.$EXT
else
 	echo "Can't deploy SNAPSHOT!"
    exit 1
fi
