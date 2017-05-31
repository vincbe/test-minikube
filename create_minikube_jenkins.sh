#!/bin/bash
# Minikube tests - Akeneo Labs - vincent.berruchon@akeneo.com
# This script will launch a minikube instance and create the Jenkins Services describe in k8s descriptor:
#   - start minikube,
#   - create the directory for the pesistant volume on the host VM
#   - create the secret configuration for Jenkins
#   - create the services : for the moment one pod for the Jenkins Master
#       TODO : creation of pods for slaves with scaling capabilities,
#         and eventually different topologies
#   - print Services and Pods (for the default namespace, probably the Jenkins pod won't be ready yet)
#

### CONST CONFIG ###
script="$0"
basename="$(dirname $script)"
K8S_YAML_DIR="${basename}"
PV_JENKINS_HOST_PATH=/data/pv-jenkins/
MINIK_STATUS=$(minikube status --format {{.MinikubeStatus}})
JENKINS_GROUP_UID=1000

### ###
#if [[ "$MINIK_STATUS"!="Stopped" ] && [ "$MINIK_STATUS"!="Does Not Exist" ]]; then
case "$MINIK_STATUS" in
  "Stopped"|"Does Not Exist")
    echo "Minikube is \"$MINIK_STATUS\". Let's go."
    ;;
  *)
    echo "ERROR: Minikube should be Stopped or non Existing. It is now \"$MINIK_STATUS\". Exit"
    exit
    ;;
esac

echo "Let's start Minikube"
minikube start

echo "Minikube VM host : $(minikube ip)"

echo "Create and define rights on the persistant volume: ${PV_JENKINS_HOST_PATH}"
minikube ssh "sudo mkdir ${PV_JENKINS_HOST_PATH} && sudo chown root:${JENKINS_GROUP_UID} ${PV_JENKINS_HOST_PATH} && sudo chmod g+w ${PV_JENKINS_HOST_PATH}"
status=$?
if [ $status -ne 0 ]; then
    echo "Error creating and defining rights on the perstitant volume: ${PV_JENKINS_HOST_PATH}"
    exit 2
fi

minikube ssh "sudo ls -lart ${PV_JENKINS_HOST_PATH}"

echo "Let's create the services (from this dir: ${K8S_YAML_DIR} ):"
# Here we use default namespace, should probably be changer for secrets:
kubectl create secret generic jenkins --from-file="${K8S_YAML_DIR}/secrets"

kubectl create -f ${K8S_YAML_DIR}

echo "Done"

kubectl get svc
kubectl get pods

echo "You'll probably have to wait a little more for your pod to be ready."

exit 0
