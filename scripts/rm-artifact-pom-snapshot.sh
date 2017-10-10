#! /bin/bash
 
 echo WORKSPACE=$WORKSPACE
 echo RM_PROJECT_GIT_NAME=$RM_PROJECT_GIT_NAME
 echo RM_PROJECT_GIT_SHA=$RM_PROJECT_GIT_SHA
 
 set -e
 cd $WORKSPACE
 # Build and deploy SNAPSHOTrm-tools.git
 git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git
 cd $RM_PROJECT_GIT_NAME
 git reset --hard $RM_PROJECT_GIT_SHA
 $MAVEN_HOME/mvn clean deploy -P artifactory -X -U
 SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
 GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^[^\[]"`
 ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[^\[]"`

 echo SNAPSHOT_VERSION=$SNAPSHOT_VERSION
 echo GROUP_ID=$GROUP_ID
 echo ARTIFACT_ID=$ARTIFACT_ID

 # Get name of latest build in artifactory and build and deploy sha file
 TIMESTAMP=$(curl "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/uk/gov/ons/ctp/product/$ARTIFACT_ID/$SNAPSHOT_VERSION/maven-metadata.xml" | \
 awk '/<timestamp>/' | \
 sed 's/<timestamp>\(.*\)<\/timestamp>/\1/' | tr -d '[:space:]')
 VERSION=$(echo $SNAPSHOT_VERSION | sed 's/\([0-9\.]*\)-SNAPSHOT/\1/')
 LATEST=$ARTIFACT_ID-$VERSION-$TIMESTAMP
 
 echo LATEST=$LATEST

 name=$(curl http://artifactory.rmdev.onsdigital.uk/artifactory/api/search/artifact?name=$LATEST | \
 grep "$LATEST.*\.pom" | \
 sed "s/.*\($LATEST.*\)\.pom.*/\1.git.sha./")$RM_PROJECT_GIT_SHA
 cd $WORKSPACE/$RM_PROJECT_GIT_NAME
 echo $RM_PROJECT_GIT_SHA | cat > $name

 export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
 curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/$GROUP_PATH/$ARTIFACT_ID/$SNAPSHOT_VERSION/$name" -T $name
