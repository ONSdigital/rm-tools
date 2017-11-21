#!/bin/bash


VERSION=$(echo *.jar | sed "s/$ARTIFACT_ID\-\([0-9\.]*\-SNAPSHOT\)\.jar/\1/")
mkdir versions

# Checking out CI branch of sdc-service-versions.git
git clone git@github.com:ONSdigital/sdc-service-versions.git ./versions
cd versions
git checkout ci

# Get new version info
SHA=$(echo $RM_PROJECT_GIT_SHA | sed 's/^\([0-9a-z]\{7\}\).*/\1/')
echo $VERSION,$SHA | cat > services/$ARTIFACT_ID.version

# Commit new version info if different
COMMIT=$(git status | grep "nothing to commit" | echo $?) # without this the script exits with a failure when there's nothing to commit
if [ $? -eq 1 ] 
then
 echo "Committing to sdc-service-versions.git"
 git commit -am "Updated $ARTIFACT_ID version in ci to $VERSION"
 git push
fi
cd ..

# Move jar to correct location
mkdir target
find . -type f -name "*.jar" -not -name "*docker-info*" -exec mv {} target/$ARTIFACT_ID.jar \;
