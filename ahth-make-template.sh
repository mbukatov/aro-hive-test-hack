#!/bin/bash

show_help()
{
  echo "Generate json template based on given ClusterDeployment CR"
  echo "Usage: $(basename "$0") [-c CLUSTER-DEPLOYMENT-NAME] -n ARO-NAMESPACE"
}

#
# main
#

if [[ $# = 0 ]]; then
  show_help
  exit
fi

# defaults
CD_NAME=cluster

while getopts "n:c:h" OPT; do
  case $OPT in
  n) NS=$OPTARG;;
  c) CD_NAME=$OPTARG;;
  h) show_help; exit;;
  esac
done

shift $(($OPTIND-1))

if [[ ! $NS ]]; then
  echo "error: namespace not specified, use -n option" >&2
  exit 1
elif [[ $NS =~ ^namespace/ ]]; then
  NS=${NS:10}
fi

if ! oc get ns/"${NS}" > /dev/null; then
  exit 1
fi

if ! oc get "cd/${CD_NAME}" -n "${NS}" -o name > /dev/null; then
  exit 1
fi

echo '{"apiVersion": "v1", "kind": "List", "items": ['

# Fetch the ClusterDeployment and immediatelly drop sections which are not
# necessary to recreate reference to the ARO cluster (status, metadata).
# By dropping spec.provisioning section, the CD resource will appear to be
# adopted, see:
# https://github.com/openshift/hive/blob/master/docs/using-hive.md#cluster-adoption
oc get ClusterDeployment/${CD_NAME} -n "${NS}" -o json \
| jq -M 'del(.status)|del(.metadata)|del(.spec.provisioning)|.metadata.name = "cluster"'

echo ","

# For secrets, we reuse them all, but drop most of the metadata but name and
# labels (removal of .metadata.ownerReference is required).
SC_LIST=($(oc get secret -n "${NS}" -o name))
SC_LAST=${SC_LIST[${#SC_LIST[@]}-1]}
for SC in ${SC_LIST[@]}; do
  oc get "${SC}" -n "${NS}" -o json \
  | jq -M 'del(.metadata.creationTimestamp)|del(.metadata.namespace)|del(.metadata.uid)|del(.metadata.resourceVersion)|del(.metadata.ownerReferences)'
  if [[ $SC != $SC_LAST ]]; then
    echo ","
  fi
done

echo "]}"
