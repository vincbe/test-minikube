
# Minikube: K8s in my laptop

You can find here a summary of a test to run a Kubernetes cluster using the minikube tool to

## K8s And Minikube WTF??

### Kubernetes
K8s is an abreviation for Kubernetes, the famous containers orchestration open-source tool from Google.
https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

### Minikube
Minikube is a faciltator tool that makes it easy to run Kubernetes locally on your laptop. Minikube runs a single-node Kubernetes cluster inside a VM for users looking to try out Kubernetes or develop with it day-to-day.
https://github.com/kubernetes/minikube

## Let's go Jenkins
Keys objectives of this little test:
 * step 1: run a jenkins master in Minikube
 * step 2: [TO BE COMPLETED] runs jenkins slaves nodes managed by the master.

## Minikube Installation and prerequisites

To install Minikube and pre-requisites, check this note (Ubuntu 16.04) :
[minikube-install-note](./minikube-install-note.md)

## Let's get it rollin'

### First minikube start

Now that minikube is installed with its dependencies, let's start it.
```
minikube start
```
This will create a VM hosting your local K8s cluster.

#### Setting the use of the KVM driver
By default, minikube will use VirtualBox to run its VM. To use of the KVM driver you can start your minikube each time with :
```
minikube start --vm-driver kvm
```
or set it as a persistent configuration :
```
minikube config set vm-driver kvm
```
(To be applied, we'll need : minikube delete before to start if you ever created a minikube)

#### Let's explore a bit minikube

To check your minikube status, just ask :```minikube status```

You can discover the minikube VM IP with :```minikube ip```

One of the default services that are started is a Dashboard UI to manage your local cluster.
This interface is great to see easily what is running and eventually to create or modify configurations.

The next command will start the dashboard and open the default browser to its URL : ```minikube dashboard```

This is a k8s service like another, so it's available via a dedicated port on the VM IP.
  My local URL with VBox: http://192.168.99.100:30000/#!/workload?namespace=default
  and with KVM : http://192.168.42.147:30000/#!/workload?namespace=default

### Kubectl
When starting Minikube will also configure your environment so you can use kubectl to manage your "cluster".

Here are a few commands with kubectl:

To get cluster status and URL : ```kubectl cluster-info```

Get nodes list : ```kubectl get nodes```

Create a namespace : ```kubectl create namespace jenkins```

### Minikube persistent volumes

The Minikube VM boots into a tmpfs, so most directories will not be persisted across reboots (minikube stop). However, Minikube is configured to persist files stored under the following directories in the minikube VM:
 * /data
 * /var/lib/localkube
 * /var/lib/docker
 * /tmp/hostpath_pv
 * /tmp/hostpath-provisioner

For more details about Persistent volumes : https://github.com/kubernetes/minikube/blob/master/docs/persistent_volumes.md
Here are descriptors examples to create PV and claim : https://myjavabytes.wordpress.com/2017/03/12/getting-a-host-path-persistent-volume-to-work-in-minikube-kubernetes-run-locally/









## TODO
