#!/bin/bash

# Clone TO and FROM branch, 
# copy version of each service in FROM to corresponding version in TO
SERVICES=( actionexportersvc actionsvc casesvc collectionexercisesvc \
iacsvc notifygatewaysvc samplesvc sdxgatewaysvc )
echo "FROM=$FROM"
echo "TO=$TO"
git clone git@github.com:ONSdigital/sdc-service-versions.git ./$TO
git clone git@github.com:ONSdigital/sdc-service-versions.git ./$FROM
cd $TO
git checkout $TO
cd ../$FROM
git checkout $FROM
cd ..
for SERVICE in ${SERVICES[@]}
do
	cat $FROM/services/$SERVICE.version > $TO/services/$SERVICE.version
done
cd $TO
git commit -am "Merged $FROM into $TO"
git push
