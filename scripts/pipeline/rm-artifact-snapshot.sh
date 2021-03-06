#! /bin/bash
set -e
 
echo WORKSPACE=$WORKSPACE
echo RM_PROJECT_GIT_NAME=$RM_PROJECT_GIT_NAME
echo RM_PROJECT_GIT_SHA=$RM_PROJECT_GIT_SHA
 
# Clone project
echo "Cloning $RM_PROJECT_GIT_NAME from branch $BRANCH and SHA $RM_PROJECT_GIT_SHA"
cd $WORKSPACE
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git
cd $RM_PROJECT_GIT_NAME
if [ $BRANCH != "master" ]; then git checkout $BRANCH; fi
git reset --hard $RM_PROJECT_GIT_SHA
 
# Build and deploy SNAPSHOT
echo "Building SNAPSHOT and deploying to Artifactory"
$MAVEN_HOME/mvn clean deploy -P artifactory -X -U

# Get required values
SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[0-9\.]*-SNAPSHOT$"`
GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^uk\.gov\.ons\.ctp\.[a-z]*$"`
ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[a-z\-]*$"`

echo SNAPSHOT_VERSION=$SNAPSHOT_VERSION
echo GROUP_ID=$GROUP_ID
echo ARTIFACT_ID=$ARTIFACT_ID
export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')

# Get timestamp and version of deployed artifact
echo "Getting filename of newly deployed artifact"
TIMESTAMP=$(curl "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/$GROUP_PATH/$ARTIFACT_ID/$SNAPSHOT_VERSION/maven-metadata.xml" | \
awk '/<timestamp>/' | \
sed 's/<timestamp>\(.*\)<\/timestamp>/\1/' | tr -d '[:space:]')
VERSION=$(echo $SNAPSHOT_VERSION | sed 's/\([0-9\.]*\)-SNAPSHOT/\1/')
LATEST=$ARTIFACT_ID-$VERSION-$TIMESTAMP
echo LATEST=$LATEST

# Create SHA file
echo "Creating SHA file"
name=$(curl http://artifactory.rmdev.onsdigital.uk/artifactory/api/search/artifact?name=$LATEST | \
grep "$LATEST.*\.jar" | \
sed "s/.*\($LATEST.*\)\.jar.*/\1.git.sha./")$RM_PROJECT_GIT_SHA.$BRANCH
cd $WORKSPACE/$RM_PROJECT_GIT_NAME/target
echo $RM_PROJECT_GIT_SHA | cat > $name
echo "Created SHA file $name"

# Deploy SHA file to artifactory
echo "Deploying $name to artifactory"
curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/$GROUP_PATH/$ARTIFACT_ID/$SNAPSHOT_VERSION/$name" -T $name

# Get name of latest build in artifactory and build and deploy manifest-template.yml file
if [ $# -eq 1 ] # No arg = no manifest.yml so nothing to do
then
  echo "Deploying manifest file"
  cd $WORKSPACE/$RM_PROJECT_GIT_NAME
  MANIFEST_FILENAME=$(curl http://artifactory.rmdev.onsdigital.uk/artifactory/api/search/artifact?name=$LATEST | \
  grep "$LATEST.*\.jar" | \
  sed "s/.*\($LATEST.*\)\.jar.*/\1\.manifest\-template\.yml/")
  curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/$GROUP_PATH/$ARTIFACT_ID/$SNAPSHOT_VERSION/$MANIFEST_FILENAME" -T manifest-template.yml
fi
