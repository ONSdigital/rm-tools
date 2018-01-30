#!/bin/bash

mkdir target
echo $SERVICE

# Check if deploying SNAPSHOT or not
echo $VERSION | grep "\-SNAPSHOT"
if [ $? -eq 1 ]
then
  # Get release build from artifactory)
  echo "Deploying RELEASE $VERSION to $SPACE"
  echo "${RELEASE_URL}/$SERVICE/$VERSION/$SERVICE-$VERSION.$EXT"
  curl ${RELEASE_URL}/$SERVICE/$VERSION/$SERVICE-$VERSION.$EXT > target/${SERVICE}.$EXT
  # Check if file is not empty (because it's not in artifactory)
  if [ $(wc -c <"target/${SERVICE}.$EXT") -lt 8000000 ]; then echo "No Jar available in artifactory, deploy failed.";exit 1;fi
else
  echo SHA=$SHA
  echo "Deploying SNAPSHOT $VERSION to $SPACE"
  # Find latest version 
  TIMESTAMP=$(curl ${ARTIFACTORY_URL}/artifactory/api/search/artifact?name=$SERVICE* | grep -m 1 ".*$SHA[0-9a-z]\{33\}" | \
    sed "s/.*$SERVICE\-\(.*\)\.git.*/\1/")
  echo TIMESTAMP=$TIMESTAMP
  # Get SNAPSHOT build from artifactory
  echo "CURLING: ${SNAPSHOT_URL}/$SERVICE/$VERSION-SNAPSHOT/$SERVICE-$TIMESTAMP.$EXT"
  curl ${SNAPSHOT_URL}/$SERVICE/$VERSION-SNAPSHOT/$SERVICE-$TIMESTAMP.$EXT > target/${SERVICE}.$EXT
fi
