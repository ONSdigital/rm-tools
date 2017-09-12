# Get release Details

echo WORKSPACE=$WORKSPACE
echo RM_PROJECT_GIT_NAME=$RM_PROJECT_GIT_NAME
echo RM_PROJECT_GIT_SHA=$RM_PROJECT_GIT_SHA

set -e
cd $WORKSPACE/
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git
cd $RM_PROJECT_GIT_NAME
git reset --hard $RM_PROJECT_GIT_SHA
$MAVEN_HOME/mvn versions:set -DremoveSnapshot=true
$MAVEN_HOME/mvn dependency:tree | awk '/uk.gov.ons.ctp.product.*SNAPSHOT:compile/{err = 1} END {exit err}'
RELEASE_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
git checkout -b $RELEASE_VERSION
git push origin $RELEASE_VERSION
GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^[^\[]"`
ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[^\[]"`
RELEASE_FILENAME=$ARTIFACT_ID-$RELEASE_VERSION

echo RELEASE_VERSION=$RELEASE_VERSION
echo GROUP_ID=$GROUP_ID
echo ARTIFACT_ID=$ARTIFACT_ID
echo RELEASE_FILENAME=$RELEASE_FILENAME

# Deploy Release to artifactory
$MAVEN_HOME/mvn clean deploy
if [ $# -eq 0 ]
then
  export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
  curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/manifest-template-$RELEASE_VERSION.yml" -T manifest-template.yml
  if [ $? -ne 0 ]; then exit 1;  fi
fi

# Tag Release
git commit -am "RELEASE CANDIDATE $RELEASE_VERSION"
git push --set-upstream origin $RELEASE_VERSION

# Update Snapshot Version no on master
cd $WORKSPACE
mkdir master
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git ./master
cd master
$MAVEN_HOME/mvn versions:set -DnextSnapshot=true
SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
git pull
git commit pom.xml -m "Update Snapshot version to $SNAPSHOT_VERSION after Release $RELEASE_VERSION"
git push

