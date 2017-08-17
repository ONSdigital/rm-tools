#!/bin/bash

###
# Before running run chmod +x svcbuild.sh to make it executable
# Run for the first time in the directory containing all of your cloned repositories with ./svcbuild.sh
###

if ! grep -q "export CODE" ~/.bash_profile
then
  echo "!!WARNING!! This script must be run for the first time from the directory containing your rm git repositories"
  echo "If you have not done this, run './svcbuild --reset' and run it there again."
  echo ""
  echo "Setting code directory"
  echo "export CODE=$PWD" | cat >> ~/.bash_profile
  . ~/.bash_profile
  cp svcbuild.sh /usr/local/bin/svcbuild
fi
declare -a services
declare -a paths
run=0
build=0
pull=0
help=$'Usage: [-p] [-b] [-r] [-api] [-svc] [-all] [svc1 ...]
      -b to build a service followed by the service codes
      -p to pull a service followed by the service codes
      -r to run a service followed by the service codes
      -api to choose all api use (except NotifyGatewayApi/Reports)
      -svc to choose all services (except Notify/SDXGateway)
      -all to choose everything (except Notify/SDXGateway/Reports)
      --reset removes all mention of the script
      The service codes are as follows:

      ActionExporter        | ax
      ActionService         | ac
      CaseSevice            | ca
      iac-service           | ia
      CollectionExercise    | cx
      NotifyGatewaySevice   | no
      SDXGatewaySvc         | sdx

      ActionServiceApi      | aca
      CaseSeviceApi         | caa
      iac-serviceApi        | iaa
      CollectionExerciseApi | cxa
      PartySeviceApi        | cxa
      SurveySeviceApi       | cxa
      SampleSeviceApi       | cxa
      CollectionInstApi     | cxa
      NotifyGatewayApi      | noa
      ReportModule          | rep'

error=$'Command not found!
      Type --help | -h for usage'

function tab() {
  osascript 2>/dev/null <<EOF
    tell application "System Events"
      tell process "Terminal" to keystroke "t" using command down
    end
    tell application "Terminal"
      activate
      do script with command "$cmd" in window 1
    end tell
EOF
}

function dostuff() {
  length=${#paths[@]}
  declare -i i=0
  until [ $i -eq $length ]
  do
    if [[ ${services[$i]} != *"Api"* ]]
    then
      cmd="clear"
      cmd="$cmd;cd '$CODE/${paths[$i]}'"
      cmd="$cmd;echo 'cd ${paths[$i]}'"
    else
      cmd="echo 'cd ${paths[$i]}'"
    fi
    if [ $pull == 1 ]
    then
       cmd="$cmd;echo 'pulling ${services[$i]}'"
       cmd="$cmd;git pull"
    fi
    if [ $build == 1 ]
    then
       cmd="$cmd;echo 'building ${services[$i]}'"
       cmd="$cmd;mvn clean install"
    fi
    if [ $run == 1 ]
    then
      if [[ ${services[$i]} == *"Api"* ]]
      then
        cmd="$cmd;echo 'Cannot run Apis!'"
      else
       cmd="$cmd;echo 'running ${services[$i]}'"
       cmd="$cmd;mvn spring-boot:run"
     fi
    fi
    if [[ ${services[$i]} == *"Api"* ]]
    then
      IFS=';' read -ra CMD <<< "$cmd"
      for j in "${CMD[@]}"; do
        cd $CODE/${paths[$i]}
        echo $(eval $j)
      done
      i=$i+1
      cd ..
    else
      i=$i+1
      tab
    fi
  done
}

if [[ $1 == '--help' || $1 == '-h' ]]
then
  if [ $# -eq 1 ]
  then
    echo "$help"
  else echo "$error"
  exit 0
  fi
elif [ $1 == '--reset' ]
then
  rm /usr/local/bin/svcbuild
  sed -ie 's/export CODE=.*$//' $HOME/.bash_profile
elif [ $# -eq 0 ]
then
  echo "$help"
else
  for arg in "$@"
  do
    case "$arg" in
      -b)
         build=1
         shift
         ;;
      -p)
         pull=1
         shift
         ;;
      -r)
         run=1
         shift
         ;;
     -api)
         services=("ActionSeviceApi" "CaseSeviceApi" "CollectionExerciseSeviceApi" \
         "CollectionInstrumentApi" "IacSeviceApi" "SampleSeviceApi" "PartySeviceApi" \
         "SurveySeviceApi" "ReportModule")
         paths=("rm-actionsvc-api/" "rm-casesvc-api/" "rm-collectionexercisesvc-api/" \
         "rm-collectioninstrumentsvc-api/" "rm-iacsvc-api/" "rm-samplesvc-api/" "rm-party-service-api/" \
         "rm-surveysvc-api/" "rm-reportmodule/" )
         ;;
     -svc)
         services=("ActionExporter"  "ActionSevice" "CaseSevice" "CollectionExerciseSevice" \
         "IacSevice" "SampleSevice" "NotifyGatewaySevice" "SDXGateway" )
         paths=("rm-actionexporter-service/" "rm-action-service/" "rm-case-service/" "rm-collection-exercise-service/" \
         "iac-service/" "rm-sample-service/" "rm-sdx-gateway" )
         ;;
     -all)
         services=("ActionSeviceApi" "CaseSeviceApi" "CollectionExerciseSeviceApi" \
         "CollectionInstrumentApi" "IacSeviceApi" "SampleSeviceApi" "PartySeviceApi" \
         "SurveySeviceApi" "ReportModule"\
         "ActionExporter" "ActionSevice" "CaseSevice" "CollectionExerciseSevice" \
         "IacSevice" "SampleSevice" "NotifyGatewaySevice" )
         paths=("rm-actionsvc-api/" "rm-casesvc-api/" "rm-collectionexercisesvc-api/" \
         "rm-collectioninstrumentsvc-api/" "rm-iacsvc-api/" "rm-samplesvc-api/" "rm-party-service-api/" \
         "rm-surveysvc-api/" "rm-reportmodule/" \
         "rm-actionexporter-service/" "rm-action-service/" "rm-case-service/" "rm-collection-exercisesvc-service/" \
         "iac-service/" "rm-sample-service/" )
         ;;
      ax)
         services[${#services[@]}]="ActionExporter"
         paths[${#paths[@]}]="rm-actionexporter-service/"
         ;;
      ac)
         services[${#services[@]}]="ActionSevice"
         paths[${#paths[@]}]="rm-action-service/"
         ;;
      ca)
        services[${#services[@]}]="CaseSevice"
        paths[${#paths[@]}]="rm-case-service/"
        ;;
      cx)
         services[${#services[@]}]="CollectionExerciseSevice"
         paths[${#paths[@]}]="rm-collection-exercise-service/"
         ;;
      ia)
         services[${#services[@]}]="IacSevice"
         paths[${#paths[@]}]="iac-service/"
         ;;
      sa)
         services[${#services[@]}]="SampleSevice"
         paths[${#paths[@]}]="rm-sample-service/"
         ;;
      no)
         services[${#services[@]}]="NotifyGatewaySevice"
         paths[${#paths[@]}]="rm-notify-gateway/"
         ;;
     sdx)
         services[${#services[@]}]="SDXGateway"
         paths[${#paths[@]}]="rm-sdx-gateway"
         ;;
      aca)
         services[${#services[@]}]="ActionSeviceApi"
         paths[${#paths[@]}]="rm-actionsvc-api/"
         ;;
      caa)
         services[${#services[@]}]="CaseSeviceApi"
         paths[${#paths[@]}]="rm-casesvc-api/"
         ;;
      cxa)
         services[${#services[@]}]="CollectionExerciseSeviceApi"
         paths[${#paths[@]}]="rm-collectionexercisesvc-api/"
         ;;
      cia)
         services[${#services[@]}]="CollectionInstrumentApi"
         paths[${#paths[@]}]="rm-collectioninstrumentsvc-api/"
         ;;
      iaa)
         services[${#services[@]}]="IacSeviceApi"
         paths[${#paths[@]}]="rm-iacsvc-api/"
         ;;
      saa)
         services[${#services[@]}]="SampleSeviceApi"
         paths[${#paths[@]}]="rm-samplesvc-api/"
         ;;
      paa)
         services[${#services[@]}]="PartySeviceApi"
         paths[${#paths[@]}]="rm-party-service-api/"
         ;;
      sua)
         services[${#services[@]}]="SurveySeviceApi"
         paths[${#paths[@]}]="rm-surveysvc-api/"
         ;;
      noa)
         services[${#services[@]}]="NotifyGatewaySevice-Api"
         paths[${#paths[@]}]="rm-notifygatewaysvc-api/"
         ;;
      *)
         echo "$error"
         exit 0
         ;;
    esac
  done
  dostuff $paths $service
fi
