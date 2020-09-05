# kubernetes-workflow-engine



## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
This project is designed to provide the best solution for problem statement: Many complicated systems (like Media file processing, Data processing) need their data or process to be in a specific state, or tasks to be running at specific times. While we can use tools like Cron to schedule tasks, the implicit dependencies between different tasks may quickly become unmanageable. By explicitly defining how our tasks depend on each other in the same place you define when they should run, it becomes much easier to work out where something went wrong. Using native orchestration procedures, we’ll also spend less time setting up new tasks, fitting them into our existing workflows, and spinning up hardware to run them on requirement basis in anauto-scaling topology. Legacy job schedulers with Kubernetes job and wondering how to write sequential jobs as a Kubernetes job.
	
## Technologies
Project is created with:
* Kubernetes: 1.17
* Argo: v2.2.1
* Java: 1.8
* Bash: 4.1
* Linux: debian, alpine
* Docker: 19.03.6-ce, build 369ce74
* containerd: 1.3.4 
* python: 3.6
* openebs: 2.0.0
* tomcat: 8
	
## Setup

* [openebs setup](#openebs-setup)
* [workflow engine setup](#workflow-engine-setup)
* [kubernetes prerequisites setup](#kubernetes-prerequisites-setup)
* [frontend setup](#frontend-setup)
* [financial processor setup](#financial-processor-setup)


### openebs-setup
To setup the openebs as storage class provisioner and automating volume provisioning follow the instructions below.

The user need to run the openebs storage provisioner in k8s cluster. openebs is basically going to be the storage class provisioner for persistent volume (pv and persistent volume claim (pvc) requirement. using openebs storage class we are going to create required volumes for all running containers. and the storage is going to be shared across all containers (sequntial & parallel).

N.B; As the Local PV storage classes use waitForFirstConsumer, do not use nodeName in the Pod spec to specify node affinity. If nodeName is used in the Pod spec, then PVC will remain in pending state.

```
$ kubectl apply -f https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/openebs/openebs-install.yaml

```

the user can verify the provisioned storage class by running the below command

```

$ kubectl get storageclasses | grep "openebs-hostpath"

```
Now the user need to create a persistent volume claim (pvc) which will be consumed by all running containers

```

$ kubectl apply -f https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/openebs/local-hostpath-pvc.yaml

```

Once the pvc gets created, you may notice the pvc is in pending state. This is just a warnng stating that the pvc will not be bound until the consumer (any running pod) is not consuming this storage.
Once the consumer aka POD gets into running state the pvc will be automatically bound to the dynamic pv managed by openebs storageclass.

### workflow-engine-setup

Workflow engine is the backend engine in the complete solution, which takes care of dynamically created containers to execute on event basis. And it controls the sequential and parallel execution of jobs being executed as a petal of the workflow.

To create the workflow-engine run the below command.

```
$ kubectl apply -f https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/workflowengine/bluetron-workflow-engine.yaml

```
once the resources get created you can list them by using the below command:

```
$ kubectl get all -n workflow-engine

```

The users can now access the workflow ui using the exposed NodePort "32206" with kubernetes cluster's public i.p "http://kubernetes.cluster.public.ip:32206"


### kubernetes-prerequisites-setup

Create a namespace called "bluetron"

```
$ kubectl create ns bluetron

```
deploy the frontend for the bluetron dataprocessor engine.

```


```


### financial-processor-setup

Deploy the financial processor using the below steps:

findout the secret name by using below command:

```
$ kubectl get secret -n bluetron|grep "bluetron-admin"

```
replace the value "$(nameOfSecret)" in the manifest file "https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/financialprocessor/bluetron-financial-processor.yaml" with the output in previous command.

Apply the modified version of manifest i.e; bluetron-financial-processor.yaml using the below command:

```
$ kubectl apply -f bluetron-financial-processor.yaml

```
Users can verify the deployment using the below command:

```
$ kubectl get all -n bluetron | grep "bluetron-financial-processor"

```

```
