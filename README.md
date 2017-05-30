
# Minikube: A mini K8s in my laptop

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

## Installation and prerequisites

I'm running this test on my brand new Dell XPS 13 laptop freshly installed with Ubuntu 16.04.
To achiveve it you'll need:
 * a supported hypervisor to run your minikube VM. For linux you can choose between VirtualBox or KVM (VT-x/AMD-v virtualization must be enabled in BIOS)
 * kubectl : a command line tool to manage a Kubernetes cluster. The easiest way to get it is to install it with Google Cloud SDK.
 * minikube : the command line exec that will manage your mononode K8s.

### Install VirtualBox as hypervisor

I had a few problems to solve because of the UEFI Secure boot of my XPS 13 Laptop that I first didn't deactivate.
So the easiest way is clearly to deactivate it. But I also present the way to keep it on and make VBox works.

To install VirtualBox on Ubuntu, don't use the .deb installation from the VBox site but the one from system packaged with dkms:
virtualbox-dkms
and you'll also need to install : linux-headers-generic

Basically after you install those two packages you also need to do the reconfiguration:
```
sudo dpkg-reconfigure virtualbox-dkms
sudo dpkg-reconfigure virtualbox
sudo modprobe vboxdrv
```
And to fix the network interface :```
sudo modprobe vboxnetflt```

#### To keep UEFI Secure Boot on
If you keep UEFI Secure Boot on, you can't use the unsigned vbox modules drivers. So you'll have to sign and you'll have to do of course each time you'll update them.
Here is a link describing a solutions to sign modules to each kernel/module updates.:
https://stegard.net/2016/10/virtualbox-secure-boot-ubuntu-fail/


### The KVM alternative
To go with KVm instead of VirtualBox you'll need the Docker Machine driver for KVM:
So first install docker-machine by heading over to https://github.com/docker/machine/releases
```
curl -L https://github.com/docker/machine/releases/download/v0.11.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
```

Then, the KVM driver:  https://github.com/dhiltgen/docker-machine-kvm/releases
```
  curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-ubuntu16.04 > /usr/local/bin/docker-machine-driver-kvm \
  chmod +x /usr/local/bin/docker-machine-driver-kvm
```

### Install Google Cloud SDK and kubectl

To install kubectl easily, let install Google Cloud SDK.

### Install the Google Cloud SDK
https://cloud.google.com/sdk/

The installation of the Google Cloud SDK via the package manager doesn't work with my Ubuntu distribution,
so to install, it's simpler (for experimentations) to use curl|bash from the web  :
```
    sudo apt-get update
    sudo apt-get remove google-cloud-sdk
    curl -sSL https://sdk.cloud.google.com | bash -
    exec -l $SHELL
    gcloud init
    gcloud components list
```

#### Installing kubectl
Install kubectl with the gcloud CLI.
```
gcloud components install kubectl
gcloud components list
```

### Finally Install Minikube

Quick presentation: https://github.com/kubernetes/minikube

Install Minikube according to the instructions for the latest release:
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.19.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```
To test it's OK, you can try : ``` minikube status```

#### Setting the use of the KVM driver
By default, minikube will use VirtualBox, use of the KVM driver you can start your minikube each time with :
```
minikube start --vm-driver kvm
```
or set it as a persistent configuration :
```
minikube config set vm-driver kvm
```
(To be applied, we'll need : minikube delete before a start)


## Let's get it rollin'






## TODO
