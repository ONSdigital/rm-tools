#!/bin/bash
TOKEN=$1
JENKINS=$2
JOBNAME=CTP_Cucumber_9_Notify_Gateway
BUILD_NO=lastBuild
declare -i I=0
while [ $I -lt 17 ]
do
  echo JOBNAME: $JOBNAME
  echo BUILD_NO: $BUILD_NO
  STATUS=$(curl "http://$TOKEN@$JENKINS/job/$JOBNAME/$BUILD_NO/api/json" | grep \"result\"\:\"SUCCESS\")
  if [ $? -eq 1 ]
  then
    echo "FAILURE on $JOBNAME : $BUILD_NO"
    exit 1
  fi
  JOBNAME=$(echo $STATUS | sed 's/.*Started by upstream project \\"\(CTP\_Cucumber\_[0-9]\{2\}_[a-zA-Z\_]*\)\\".*/\1/' )
  BUILD_NO=$(echo $STATUS | sed 's/.*\"upstreamBuild\"\:\([0-9]*\).*/\1/')
  I=$I+1
done
echo "All tests passed!"

mkdir SUCCESSFUL_CONFIG_$TS

git clone git@github.com:ONSdigital/sdc-service-versions.git
cd sdc-service-versions
git checkout ci

cp services/* ../SUCCESSFUL_CONFIG_$TS

git checkout ci-successful-config
cp ../SUCCESSFUL_CONFIG_$TS .
git commit -am "Full test success"
