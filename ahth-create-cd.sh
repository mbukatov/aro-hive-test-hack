#!/bin/bash

show_help()
{
  echo "Create ClusterDeployment CR based on given json template"
  echo "Usage: $(basename "$0") [-d] -t TEMPLATE -n ARO-NAMESPACE [-s START] [-e END]"
}

create_cd()
{
  local TEMPLATE=$1
  local NS=$2
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

while getopts "dn:t:s:e:h" OPT; do
  case $OPT in
  d) DEBUG=echo;;
  n) NS=$OPTARG;;
  t) TEMPLATE=$OPTARG;;
  s) N_START=$OPTARG;;
  e) N_END=$OPTARG;;
  h) show_help; exit;;
  esac
done

shift $(($OPTIND-1))

if [[ ! $TEMPLATE ]]; then
  echo "error: template not specified, use -t option" >&2
  exit 1
fi

if [[ ! $DEBUG ]]; then
  set -ex
fi

if [[ ${N_START} -gt 0 && ${N_END} -gt ${N_START} ]]; then
  for i in $(seq -f "%05g" $N_START $N_END); do
    NS_I=${NS}-${i}
    create_cd ${TEMPLATE} ${NS_I}
  done
else
  create_cd ${TEMPLATE} ${NS}
fi
