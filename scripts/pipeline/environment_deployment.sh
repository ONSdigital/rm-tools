#!/bin/bash
cd services
echo ${ENV}
SERVICES=( actionexportersvc actionsvc casesvc collectionexercisesvc \
iacsvc notifygatewaysvc samplesvc sdxgatewaysvc )

# For each service deploy new version if it's different to the current deployed version
for SERVICE in ${SERVICES[@]}
do

	# Check current and new version
	VERSION=$(grep -oE  "[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,3}[-SNAPHOT]{0,9}" $SERVICE.version)
	SHA=$(grep -oE "[0-9a-z]{7}" $SERVICE.version)
    DEPLOYED=$(curl -s $SERVICE-$ENV.$URL/info | grep -oE "\"version\"\:\"[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,3}[-SNAPHOT]*" | grep -oE "[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,3}[-SNAPHOT]*")
	if [ "$DEPLOYED" != "$VERSION" ]
    then
    	echo "Deployed $SERVICE version is $DEPLOYED, Deploying version $VERSION to $ENV"
		TMP="concat(//crumbRequestField,\":\",//crumb)"
        CRUMB=$(curl -s "$URL/crumbIssuer/api/xml?xpath=${TMP}")
        echo $CRUMB
        echo "Building: $URL/job/Deploy_${SERVICE}_$ENV/build"
        if [ "$ENV" == "sit" ]
        then
          # Passing Release tag as a parameter for SIT
          DATA="{"parameter": [{\"name\":\"VERSION\", \"value\":\"$VERSION\"},{\"name\":\"SHA\", \"value\":\"$SHA\"},{\"name\":\"SERVICE\", \"value\":\"$SERVICE\"},{\"name\":\"RELEASE_TAG\", \"value\":\"${RELEASE_TAG}\"}]}"
        else
          DATA="{"parameter": [{\"name\":\"VERSION\", \"value\":\"$VERSION\"},{\"name\":\"SHA\", \"value\":\"$SHA\"},{\"name\":\"SERVICE\", \"value\":\"$SERVICE\"}]}"
        fi
        curl -X POST -H "$CRUMB" "$URL/job/Deploy_${SERVICE}_$ENV/build" \
          --data-urlencode json="$DATA"
    else
    	echo "$SERVICE version $VERSION already deployed to $ENV"
    fi
done
