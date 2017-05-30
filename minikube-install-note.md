# Minikube Installation and prerequisites

I'm running this test on my brand new Dell XPS 13 laptop freshly installed with Ubuntu 16.04. So most of the commands for this installation are quite specific to this OS. Adapt to your own box and specificities.

To run Minikube you'll need:
 * a supported hypervisor to run your minikube VM. For linux you can choose between VirtualBox or KVM (VT-x/AMD-v virtualization must be enabled in BIOS)
 * kubectl : a command line tool to manage a Kubernetes cluster. The easiest way to get it is to install it with Google Cloud SDK.
 * minikube : the command line exec that will create and manage your mono-node K8s.

### Install VirtualBox as hypervisor

I had different problems because of the UEFI Secure boot of my XPS 13 Laptop that I first didn't deactivate.
The easiest way to go is clearly to deactivate it. But I also present the way to keep it on and make VBox works.

To install VirtualBox on Ubuntu, don't use the .deb installation from the VBox site but the one from system packaged with dkms: ```virtualbox-dkms```
and you'll also need to install : ```linux-headers-generic```

```
sudo apt install virtualbox-dkms linux-headers-generic
```

Basically after you install those two packages you also need to do the reconfiguration:
```
sudo dpkg-reconfigure virtualbox-dkms
sudo dpkg-reconfigure virtualbox
sudo modprobe vboxdrv
```
And to fix the network interface :
```
sudo modprobe vboxnetflt
```

#### To keep UEFI Secure Boot "on"
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
To test it's installed, you can try : ``` minikube status```
