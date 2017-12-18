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

# Get required information
GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^uk\.gov\.ons\.ctp\.[a-z]*$"`
ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[a-z\-]*$"`
RELEASE_FILENAME=$ARTIFACT_ID-$RELEASE_VERSION

echo RELEASE_VERSION=$RELEASE_VERSION
echo GROUP_ID=$GROUP_ID
echo ARTIFACT_ID=$ARTIFACT_ID
echo RELEASE_FILENAME=$RELEASE_FILENAME

# Deploy Release to artifactory
echo "Deploying $RM_PROJECT_GIT_SHA to Artifactory"
$MAVEN_HOME/mvn clean deploy -Ddockerfile.skip -DskipITs
if [ $# -eq 1 ]
then
  export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
  echo $GROUP_PATH
  curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/manifest-template-$RELEASE_VERSION.yml" -T manifest-template.yml
  if [ $? -ne 0 ]; then echo "Deployment failed."; exit 1;  fi
fi
