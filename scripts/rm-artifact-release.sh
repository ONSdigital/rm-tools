# Get release Details
set -e
cd $WORKSPACE/
mkdir totag
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git ./totag
cd totag
git reset --hard $RM_PROJECT_GIT_SHA
mvn dependency:tree | awk '/uk.gov.ons.ctp.product.*SNAPSHOT:compile/{err = 1} END {exit err}'
$MAVEN_HOME/mvn versions:set -DremoveSnapshot=true
RELEASE_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^[^\[]"`
ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[^\[]"`
RELEASE_FILENAME=$ARTIFACT_ID-$RELEASE_VERSION
mv pom.xml $WORKSPACE/$RELEASE_FILENAME.pom

# Get Snapshot based on sha
JAR=$(curl http://artifactory.rmdev.onsdigital.uk/artifactory/api/search/artifact?name=$ARTIFACT_ID*$RM_PROJECT_GIT_SHA | echo$(grep "$RM_PROJECT_GIT_SHA") | \
    sed "s/.*$ARTIFACT_ID\-\(.*\)\.git\.sha\.$RM_PROJECT_GIT_SHA/\1/")
curl  http://artifactory.rmdev.onsdigital.uk/artifactory/libs-snapshot-local/uk/gov/ons/ctp/product/$ARTIFACT_ID/*$LATEST.jar
mv *.jar $WORKSPACE/$RELEASE_FILENAME.jar

# Deploy Release to artifactory
cd $WORKSPACE/
export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/$RELEASE_FILENAME.jar" -T $RELEASE_FILENAME.jar
if [ $? -ne 0 ]; then exit 1;  fi
curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/$RELEASE_FILENAME.pom" -T $RELEASE_FILENAME.pom
if [ $? -ne 0 ]; then exit 1;  fi

# Tag Release
cd $WORKSPACE/totag
git tag RELEASE_CANDIDATE_$RELEASE_VERSION
git push --tags

# Update Snapshot Version no on master
#cd $WORKSPACE
#mkdir master
#git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git ./master
#cd master
#$MAVEN_HOME/mvn versions:set -DnextSnapshot=true
#SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
#git pull
#git commit pom.xml -m "Update Snapshot version to $SNAPSHOT_VERSION after Release $RELEASE_VERSION"
#git push

