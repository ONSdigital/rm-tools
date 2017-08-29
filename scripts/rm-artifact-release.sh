# Get release Details
cd $WORKSPACE/
mkdir totag
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git ./totag
cd totag
git reset --hard $RM_PROJECT_GIT_SHA
$MAVEN_HOME/mvn release:prepare
$MAVEN_HOME/mvn versions:set -DremoveSnapshot=true
RELEASE_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
GROUP_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId | grep "^[^\[]"`
ARTIFACT_ID=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId | grep "^[^\[]"`
RELEASE_FILENAME=$ARTIFACT_ID-$RELEASE_VERSION
mv pom.xml $WORKSPACE/$RELEASE_FILENAME.pom

# Get Snapshot based on sha
cd $WORKSPACE/
git clone https://github.com/ONSdigital/rm-tools.git
cd $WORKSPACE/rm-tools/scripts
javac LatestBuild.java
java LatestBuild -g http://artifactory.rmdev.onsdigital.uk . $ARTIFACT_ID $RM_PROJECT_GIT_SHA
mv *.jar $WORKSPACE/$RELEASE_FILENAME.jar

# Deploy Release to artifactory
cd $WORKSPACE/
export GROUP_PATH=$(echo $GROUP_ID | tr '.' '/')
curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/$RELEASE_FILENAME.jar" -T $RELEASE_FILENAME.jar
curl -u build:$ARTIFACTORY_PASSWORD -X PUT "http://artifactory.rmdev.onsdigital.uk/artifactory/libs-release-local/$GROUP_PATH/$ARTIFACT_ID/$RELEASE_VERSION/$RELEASE_FILENAME.pom" -T $RELEASE_FILENAME.pom

# Tag Release
cd $WORKSPACE/totag
git tag RELEASE_CANDIDATE_$RELEASE_VERSION
git push --tags

# Update Snapshot Version no on master
cd $WORKSPACE
mkdir master
git clone git@github.com:ONSdigital/$RM_PROJECT_GIT_NAME.git ./master
cd master
$MAVEN_HOME/mvn versions:set -DnextSnapshot=true
SNAPSHOT_VERSION=`$MAVEN_HOME/mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version | grep "^[^\[]"`
git commit pom.xml -m "Update Snapshot version to $SNAPSHOT_VERSION after Release $RELEASE_VERSION"
git push

