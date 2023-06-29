#!/bin/bash

show_help()
{
  echo "Create ClusterDeployment CR based on given json template"
  echo "Usage: $(basename "$0") [-d] -t TEMPLATE -n ARO-NAMESPACE"
}

create_cd()
{
  TEMPLATE=$1
  NS=$2
  if ! oc get ns/"${NS}" > /dev/null; then
    $DEBUG oc create namespace $NS
  fi
  $DEBUG oc create -f $TEMPLATE -n $NS
}

#
# main
#

if [[ $# = 0 ]]; then
  show_help
  exit
fi

unset DEBUG

while getopts "dn:t:h" OPT; do
  case $OPT in
  d) DEBUG=echo;;
  n) NS=$OPTARG;;
  t) TEMPLATE=$OPTARG;;
  h) show_help; exit;;
  esac
done

shift $(($OPTIND-1))

if [[ ! $DEBUG ]]; then
  set -ex
fi

create_cd ${TEMPLATE} ${NS}
