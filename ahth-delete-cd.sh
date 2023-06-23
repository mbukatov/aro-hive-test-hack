#!/bin/bash

show_help()
{
  echo "Force delete all ClusterDeployment CRs in given namespace."
  echo "Usage: $(basename "$0") [-d] -n <namespace-to-delete>"
}

#
# main
#

if [[ $# = 0 ]]; then
  show_help
  exit
fi

unset DEBUG

while getopts "dn:h" OPT; do
  case $OPT in
  d) DEBUG=echo;;
  n) NS=$OPTARG;;
  h) show_help; exit;;
  esac
done

shift $(($OPTIND-1))

if [[ ! $DEBUG ]]; then
  set -ex
fi

if [[ ! $NS ]]; then
  echo "error: namespace not specified, use -n option" >&2
  exit 1
elif [[ $NS =~ ^namespace/ ]]; then
  NS=${NS:10}
fi

for CD_CR in $(oc get ClusterDeployment -n "${NS}" -o name); do
  # workaround for https://issues.redhat.com/browse/HIVE-2249
  # should not be necessary with https://github.com/openshift/hive/pull/2050
  ${DEBUG} oc patch  "${CD_CR}" -p '{"metadata":{"finalizers":null}}' --type=merge -n "${NS}"
  ${DEBUG} oc delete "${CD_CR}" -n "${NS}"
done
${DEBUG} oc delete "ns/${NS}" --timeout=2s
