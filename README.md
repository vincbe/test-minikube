
# Minikube: K8s in my laptop

You'll find here a summary to run a Kubernetes cluster using the minikube tool on your laptop. The application used is Jenkins but could be any application packaged in a Docker image (or even another container image as rkt).

This little example is still "in progress" and should be updated but that it can yet allow you to launch your first services in minikube as a local k8s cluster.

## K8s And Minikube WTF??

### Kubernetes
K8s is an abreviation for Kubernetes, the famous containers orchestration engine from Google. This tool is an open-source one and one of the most advanced tools to orchestrate containers.
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

## Step 1 - Let's get it rollin'

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

Get services list : ```kubectl get svc  ```

Get nodes list : ```kubectl get nodes```

#### Namespaces
By default, thoses commands will show only elements from the "default" namespace.
You can list existing namespaces with ```kubectl get namespaces``` or its abreviated form :
```
$ kubectl get ns
NAME          STATUS    AGE
default       Active    7d
kube-public   Active    7d
kube-system   Active    7d
```
By default you can see that 3 namespaces exists.

To consult elements within a specific namespace, add it to your command with ```-n <namespace>```
```
$ kubectl -n kube-system get svc
NAME                   CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns               10.0.0.10    <none>        53/UDP,53/TCP   7d
kubernetes-dashboard   10.0.0.134   <nodes>       80:30000/TCP    7d
```

So if you create a new namespace : ```kubectl create namespace jenkins```
Remember to add ```-n jenkins``` to check its elements.


## Let's deploy Jenkins

Now that our Minikube is up we can deploy services on it.
We'll first create a Jenkins Master using a docker image with the plugins we need.
To do so, in kubernetes model we'll have to create a "pod" to run the "jenkins-master" container and two services to expose the Jenkins Web UI and the Jenkins discovery.
We'll also need a persistent volume to persist Jenkins data when we stop our minikube cluster.
To manage secrets, Kubernetes offer an internal services so we'll use it to define the jenkins credentials and allow the container to get them.

Our goal could be to get something like that :
![https://cloud.google.com/solutions/images/jenkins-kubernetes-architecture.svg]

### Pods
Let's stop a bit on this concept:
> The concept of a pod in Kubernetes makes it easy to tag multiple containers that are treated as a single unit of deployment. They are co-located on the same host and share the same resources, such as network, memory and storage of the node. Each pod gets a dedicated IP address that’s shared by all the containers belonging to it. That’s not all – each container running within the same pod gets the same hostname, so that they can be addressed as a unit.
> ...
> When a pod is scaled out, all the containers within it are scaled as a group.
> ...
> Simply put, a pod is just a manifest of multiple container images managed together.
Ref :[https://thenewstack.io/kubernetes-way-part-one/]

### Services
To access and expose the pods managed by k8s will also create services:
>Services in Kubernetes consistently maintain a well-defined endpoint for pods.
>The service manifest has the right labels and selectors to identify and group multiple pods that act as a microservice.
>For example, all the Apache web server pods running on any node of the cluster that matches the label “frontend” will become a part of the service. It’s an abstraction layer that brings >multiple pods running across the cluster under one endpoint.
Ref :[https://thenewstack.io/kubernetes-way-part-one/]

### Persistent volumes
Container loves stateless application but sometimes we want to persist data even if the container is removed.
Different providers for "PV" are available depending of the cloud provider or infrastructure we're running on. With Minikube we will be very limited to persistant directories on the minikube VM.
As PV are storage ressources, pods won't attach directly created PV but claim for available PV via a claim to get what they need.

#### Minikube persistent volumes

The Minikube VM boots into a tmpfs, so most directories will not be persisted across reboots (minikube stop). However, Minikube is configured to persist files stored under the following directories in the minikube VM:
 * /data
 * /var/lib/localkube
 * /var/lib/docker
 * /tmp/hostpath_pv
 * /tmp/hostpath-provisioner

For more details about Persistent volumes : https://github.com/kubernetes/minikube/blob/master/docs/persistent_volumes.md
Here are descriptors examples to create PV and claim : https://myjavabytes.wordpress.com/2017/03/12/getting-a-host-path-persistent-volume-to-work-in-minikube-kubernetes-run-locally/

### Configuration via YAML descriptors

<b>We can describe thoses various element to configure in YAML files. We will use the kubectl CLI to create them and of course it will be easy to version thoses in a Git repo (or any  SCM).</b>

So here are the files to begin with the configuration of our Jenkins. Let's give a look at them :

#### First we create a PV : pv-jenkins.yaml
We don't have much options using Minikube, so we'll use a directory under /data with a capacity of 5Gb.
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-jenkins
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 5Gi
  hostPath:
    path: /data/pv-jenkins/
```
As we see this PV is accessible in Read/Write mode but only by one container at a time.

Using minikube, the directories created on the underlying hosts are only writable by root.
So you either need to run your process as root in a privileged container or modify the file permissions on the host to be able to write to a hostPath volume.
That's not very acceptable and my Jenkins image will use the standard jenkins user (uid=1000) so if I don't want to go root and privileged, I need to find a way to apply this:

Connect to the minikube host :
```
minikube ssh
```
and apply the rights to he directory we want to use:
```
$ sudo mkdir -p /data/pv-jenkins/
$ sudo chmod +gW /data/pv-jenkins/
$ sudo chown root:1000 /data/pv-jenkins/  
```

#### Then a PV claim : jenkins-pv-claim.yaml

To keep it simple, we'll make a claim that we'll precise the volumeName that match the created PV.
```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jenkins-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  volumeName: pv-jenkins
```

#### jenkins-master.yaml

To define our pods , we'll declare what we want to deploy (kind:Deployment).
As our master will be unique, we want only one replica and we set the image we want to use to create the container from.
We also declare ports that the container will expose.
K8s will also set some environment variables from secrets we'll have to create soon in our cluster.
We can see that we use the PV claim to mount our data volume.

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: jenkins-master
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: jenkins-master
    spec:
      containers:
      - name: jenkins-master
        image: vberruchon/akn_jenkins_master:0.0.3
        ports:
        - containerPort: 8080
        - containerPort: 50000
        env:
        - name: JENKINS_PASS
          valueFrom:
            secretKeyRef:
              name: jenkins
              key: jenkins_pass
        - name: JENKINS_OPTS
          valueFrom:
            secretKeyRef:
              name: jenkins
              key: jenkins_options
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pv-claim
```

#### service_jenkins.yaml

And finaly, two services are defined:
 * one for the Web UI (jenkins-ui) :  An externally-exposed NodePort service on port 8080 that allows pods and external users to access the Jenkins user interface. This type of service can be load balanced by an HTTP load balancer.
 * another for the service discovery (jenkins-discovery) : an internal, private ClusterIP service on port 50000 that the Jenkins executors use to communicate with the Jenkins master from inside the cluster.

```
kind: Service
  apiVersion: v1
  metadata:
    name: jenkins-ui
    #namespace: jenkins
  spec:
    type: NodePort
    selector:
      app: jenkins-master
    ports:
      - protocol: TCP
        port: 8080
        targetPort: 8080
        name: ui
---
  kind: Service
  apiVersion: v1
  metadata:
    name: jenkins-discovery
    #namespace: jenkins
  spec:
    selector:
      app: jenkins-master
    ports:
      - protocol: TCP
        port: 50000
        targetPort: 50000
        name: slaves
```
### Deploy our pods and services

#### Create the secret

We define a secret that we'll be consumed by Jenkins as and environment variable for the container.

To create the secret with kubectl, we can create a file for each keys we need, the value will be set with the content of the file (be careful, if your last line is finished with a "\n", you can use echo -n to create the file).
```
kubectl create secret generic jenkins --from-file=./secrets
```

#### Creation of the deployment and services from my yaml files directory

If we want to create all elements in our YAML descriptor files, we can just use the "-f" flag of "kubectl create" command:
```
    kubectl create -f ${K8S_YAML_DIR}
```
The creation is quite quick but you'll probably have to wait a more for your containers to be created and started.

We can check what has been created in the dashboard or lists resources with the CLI:
 * kubectl get - list resources
 * kubectl describe - show detailed information about a resource
 * kubectl logs - print the logs from a container in a pod
 * kubectl exec - execute a command on a container in a pod

 For example :
 ```
 kubectl get svc
 kubectl get pods
 ```
#### Accessing the Jenkins UI

To determine the port to access to your Jenkins UI :
```
 $ kubectl get svc
NAME                CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
jenkins-discovery   10.0.0.52    <none>        50000/TCP        8d
jenkins-ui          10.0.0.127   <nodes>       8080:31096/TCP   8d
kubernetes          10.0.0.1     <none>        443/TCP          8d
```
The port is the one mapped to the 8080 for the jenkins-ui service, here 31096.
It will listen on the IP of the minikube VM (```minikube ip```).
For me it will be : http://192.168.99.100:31096/

#### Unlocking Jenkins
At first start, Jenkins will need a generated password you can get in the logs.
As container logs are directly available from the kubectl CLI you just need to find the pod name:
```
$ kubectl get pods
NAME                             READY     STATUS    RESTARTS   AGE
jenkins-master-647471806-w9nk6   1/1       Running   1          8d
```
and show the logs :
```
$ kubectl logs <pod-name>
```

### Play with it
To play or create an environment really quickly we can script all that.
You'll find a little script that should create everything and let you play.

The script start minikube, create the secret and our services+pods.
To start from a clean state, you can delete your minikube using ```minikube delete``` (as  the VM is also deleted, you'll lost your persistant storage is they are not mounted on your VBox host)

and launch th script from the directory were are your yaml files and options :
```
./create_minikube_jenkins.sh
```
You can now complete your descriptor files and test locally those changes.

## Step 2 : still to be completed
Those example only build a jenkins-master pod, we could now define "slave" pods that could share the work.

## References

* https://kubernetes.io/docs/getting-started-guides/minikube/
* https://cloud.google.com/solutions/jenkins-on-container-engine
