#!/bin/bash

mkdir target
echo $SERVICE

# Check if deploying SNAPSHOT or not
echo $VERSION | grep "\-SNAPSHOT"
if [ $? -eq 1 ]
then
  echo "Deploying RELEASE $VERSION to $SPACE"
  echo "${RELEASE_URL}/$SERVICE/$VERSION/$SERVICE-$VERSION.$EXT"
  curl ${RELEASE_URL}/$SERVICE/$VERSION/$SERVICE-$VERSION.$EXT > target/${SERVICE}.$EXT
else
  echo SHA=$SHA
  echo "Deploying SNAPSHOT $VERSION to $SPACE"
  TIMESTAMP=$(curl ${ARTIFACTORY_URL}/artifactory/api/search/artifact?name=$SERVICE* | grep -m 1 ".*$SHA[0-9a-z]\{33\}" | \
    sed "s/.*$SERVICE\-\(.*\)\.git.*/\1/")
  echo TIMESTAMP=$TIMESTAMP
  curl ${SNAPSHOT_URL}/$SERVICE/$VERSION-SNAPSHOT/$SERVICE-$TIMESTAMP.$EXT > target/${SERVICE}.$EXT
fi
