#! /bin/bash
 
 set -e
 cd $WORKSPACE
 # Build and deploy SNAPSHOT
 git clone https://github.com/ONSdigital/$RM_PROJECT_GIT_NAME.git
 cd $RM_PROJECT_GIT_NAME
 git reset --hard $RM_PROJECT_GIT_SHA
 $MAVEN_HOME/mvn clean deploy -P artifactory -X -U
 SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
 GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^[^\[]"`
 ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[^\[]"`

 # Get name of latest build in artifactory and build and deploy sha file
 TIMESTAMP=$(curl "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/uk/gov/ons/ctp/product/$ARTIFACT_ID/$SNAPSHOT_VERSION/maven-metadata.xml" | \
 awk '/<timestamp>/' | \
 sed 's/<timestamp>\(.*\)<\/timestamp>/\1/' | tr -d '[:space:]')
 VERSION=$(echo $SNAPSHOT_VERSION | sed 's/\([0-9\.]*\)-SNAPSHOT/\1/')
 LATEST=$ARTIFACT_ID-$VERSION-$TIMESTAMP
 name=$(curl http://artifactory.rmdev.onsdigital.uk/artifactory/api/search/artifact?name=$LATEST | \
 grep "$LATEST.*\.jar" | \
 sed "s/.*\($LATEST.*\)\.jar.*/\1.git.sha./")$RM_PROJECT_GIT_SHA
 cd $WORKSPACE/$RM_PROJECT_GIT_NAME/target
 echo $RM_PROJECT_GIT_SHA | cat > $name

 export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
 curl -u build:$ARTIFACTORY_PASSWORD -X PUT 
 "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/$GROUP_PATH/$ARTIFACT_ID/$SNAPSHOT_VERSION/$name" -T $name
