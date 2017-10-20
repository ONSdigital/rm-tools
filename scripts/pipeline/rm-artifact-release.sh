#!/bin/bash
set -e

# Get release Details
echo WORKSPACE=$WORKSPACE
echo RM_PROJECT_GIT_NAME=$RM_PROJECT_GIT_NAME
echo RM_PROJECT_GIT_SHA=$RM_PROJECT_GIT_SHA

# Clone project at required commit
cd $WORKSPACE/
echo "Cloning $RM_PROJECT_GIT_NAME on branch $BRANCH with SHA $RM_PROJECT_GIT_SHA"
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git
cd $RM_PROJECT_GIT_NAME
echo $BRANCH
if [ $BRANCH != "master" ]; then git checkout $BRANCH ; fi
git reset --hard $RM_PROJECT_GIT_SHA

# Make sure version is RELEASEABLE
echo "Checking POM does not depend on any SNAPSHOTs"
$MAVEN_HOME/mvn versions:set -DremoveSnapshot=true
$MAVEN_HOME/mvn dependency:tree | awk '/uk.gov.ons.ctp.product.*SNAPSHOT:compile/{err = 1} END {exit err}'

# Get release version and create new branch
RELEASE_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[0-9\.]\{7,9\}"`
echo "Creating new branch $RELEASE_VERSION"
git checkout -b $RELEASE_VERSION
git push origin $RELEASE_VERSION

# Get required information
GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^uk\.gov\.ons\.ctp\.[a-z]*$"`
ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[a-z\-]*$"`
RELEASE_FILENAME=$ARTIFACT_ID-$RELEASE_VERSION

# Check code has been tested and exists as a SNAPSHOT in artifactory
echo "Checking SNAPSHOT version exists in artifactory"
curl "http://artifactory.rmdev.onsdigital.uk/artifactory/api/search/artifact?name=$ARTIFACT_ID*" | grep $RM_PROJECT_GIT_SHA
if [ $? -ne 0 ]; then echo "NO SNAPSHOT VERSION EXISTS IN ARTIFACTORY! BUILD SNAPSHOT FIRST!"; exit 1;  fi

echo RELEASE_VERSION=$RELEASE_VERSION
echo GROUP_ID=$GROUP_ID
echo ARTIFACT_ID=$ARTIFACT_ID
echo RELEASE_FILENAME=$RELEASE_FILENAME

# Deploy Release to artifactory
echo "Deploying to Artifactory"
$MAVEN_HOME/mvn clean deploy
if [ $# -eq 1 ]
then
  export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
  echo $GROUP_PATH
  curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/manifest-template-$RELEASE_VERSION.yml" -T manifest-template.yml
  if [ $? -ne 0 ]; then echo "Deployment failed."; exit 1;  fi
fi

# Tag Release
echo "Tagging release version $RELEASE_VERSION in branch"
git commit -am "RELEASE CANDIDATE $RELEASE_VERSION"
git push --set-upstream origin $RELEASE_VERSION

# Update Snapshot Version no. on master
echo "Updating version on master"
cd $WORKSPACE
mkdir master
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git ./master
cd master
$MAVEN_HOME/mvn versions:set -DnextSnapshot=true
SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
git pull
git commit pom.xml -m "Update Snapshot version to $SNAPSHOT_VERSION after Release $RELEASE_VERSION"
git push

# Start CI deploy job
if [ $# -eq 1 ]
then
  echo "Deploying to CI"
  # Curl deploy job to deploy to CI
  TMP="concat(//crumbRequestField,\":\",//crumb)"
  CRUMB=$(curl -s "http://Build:c468255672f656e992bc18832e5347dd@jenkins.rmdev.onsdigital.uk:8080/crumbIssuer/api/xml?xpath=${TMP}")
  DATA="{"parameter": [{\"name\":\"VERSION\", \"value\":\"$VERSION\"},{\"name\":\"SHA\", \"value\":\"$SHA\"},{\"name\":\"SERVICE\", \"value\":\"$SERVICE\"}]}"
	curl -X POST -H "$CRUMB" "http://Build:c468255672f656e992bc18832e5347dd@jenkins.rmdev.onsdigital.uk:8080/job/Deploy_$ARTIFACT_ID_ci/build" \
	--data-urlencode json="$DATA"
	
  # Update git version repo
  echo "Updating sdc-service-versions repo with new CI version"
  mkdir versions
  git clone git@github.com:ONSdigital/sdc-service-versions.git ./versions
  cd versions
  git checkout ci
  SHA=$(echo $RM_PROJECT_GIT_SHA | sed 's/^\([0-9a-z]\{7\}\).*/\1/')
  echo $RELEASE_VERSION,$SHA | cat > services/$ARTIFACT_ID.version
  git commit -am "Updated $ARTIFACT_ID version in ci to $RELEASE_VERSION"
  git push
fi




