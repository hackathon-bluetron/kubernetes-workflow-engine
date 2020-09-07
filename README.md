# kubernetes-workflow-engine



## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
This project is designed to provide the best solution for problem statement: Many complicated systems (like Media file processing, Data processing) need their data or process to be in a specific state, or tasks to be running at specific times. While we can use tools like Cron to schedule tasks, the implicit dependencies between different tasks may quickly become unmanageable. By explicitly defining how our tasks depend on each other in the same place you define when they should run, it becomes much easier to work out where something went wrong. Using native orchestration procedures, we’ll also spend less time setting up new tasks, fitting them into our existing workflows, and spinning up hardware to run them on requirement basis in anauto-scaling topology. Legacy job schedulers with Kubernetes job and wondering how to write sequential jobs as a Kubernetes job.
	
## Solution

1. The solution have a Front End UI which is available at "http://169.51.204.19:30285/BluTronFinantialProcesser/",  which is an application running on the Kubernetes pod. The user provide an input in the form of an excel workbook which may contain numerous sheets. Once the excel workbook with data is added, the Front-end application calls a Java spring boot backend Microservice and sends the input as excel file. The backend microservice is exposed with an API, so when front-end microservice calls the backend unit over API an automation script automatically gets invoked in the calls the entire workflow-engine and coreprocessor 

The respective frontend containerization code (kubernetes deployment, service, frontend .war & Dockerfile is available at "https://github.com/hackathon-bluetron/kubernetes-workflow-engine/tree/master/ui"

The frontend web application code is available at "https://github.com/hackathon-bluetron/kubernetes-workflow-engine/tree/master/SpringFileUpload"

![Alt text](images/frontend.JPG?raw=true "Title")

2. The Microservice validates the input file and sends the total number of sheets present in the workbook and the sheet validation info as a response to the front-end application.

The respective backend microservice containerization code (kubernetes deployment, service, microservice jwar & Dockerfile) are available at "https://github.com/hackathon-bluetron/kubernetes-workflow-engine/tree/master/financialprocessor"

The backend springboot application code is available at "https://github.com/hackathon-bluetron/kubernetes-workflow-engine/tree/master/SpringFileUpload"

3. The microservice then triggers the workflow engine with the input excel file as an argument to the automation script. In the front-end ui we can see the validation status of excel file, depending on validation it calls the Kubernetes API through a shell script to start the workload in Acyclic Engine.

![Alt text](images/frontend_response.JPG?raw=true "Title")

4. The Acyclic Engine  manages the load and the intrinsic dependencies between the process and thereby the containers.
The Parallelism counter starts assigning tasks to the Steps Engine which would eventually create containers to be created dynamically for the workload and should accomplish the job in parallel.
Once these parallel running containers who executed individual piece of task of processing xls to csv  gets completed. The merger container comes into place.
The merge container basically merges all the csv to a combined csv file which holds all the processed raw data of input xls file.
The user will be acknowledged with the absolute path of the processed csv files available in the container backed storage.

5. All these processes automatically gets executed when the user uploads the xls file to process. and the realtime data processing through the Acyclic Engine, Parallelism counter, Steps Engine is controlled by the coreprocessor unit. The real ime data processing is accessible at "http://169.51.204.19:32206/workflows/". This is the workflow ui running as a pod in kubernetes cluster.

The workflow UI containerization code (kubernetes deployment, service, RBAC, Secret, Configmap etc) are  available at "https://github.com/hackathon-bluetron/kubernetes-workflow-engine/tree/master/workflowengine"

Workflow UI

![Alt text](images/workflow.JPG?raw=true "Title")


Individual workflow process steps.

![Alt text](images/workflow_process.JPG?raw=true "Title")


6. We have installed another UI running as pod where we do manage all the kubernetes resources. this UI is available at "http://169.51.204.19:30777/"

the operation manual of this UI is explained below


```

a. login the url here "http://169.51.204.19:30777/"

b. click on kubernetes cluster "local cluster"

c. click on Resource pool & select "bluetron" Resource pool

d. Click on "bluetron-financial-finalizer" or "bluetron-financial-processor" Application

e. Scroll down to find out the running pods.

f. Click on "Console" in bottom right corner.

g. In console command type "/bin/bash" and connect.

h. This is a virtual console to the running pods in the bluetron namespace aka Resource pool.

I. The pod is already attached with Shared PVC at mount point /mnt/data.

J. The input files brfore process is stored in this shared folder at "/mnt/data/input" & after processing the processed csv files are available "/mnt/data/output/<filename>" folder

K. The users can verify the processed csv files at the output folder

Example.

Suppose an user uploads a file named as "sample.xlsx" with 10 sheets, then the input file will be stored at "/mnt/data/input" folder and processed csv files will be available at "/mnt/data/output/sample" folder with below contents inside


Sector1.csv       Sector3.csv       Sector6.csv       Sector9.csv
Sector10.csv      Sector4.csv       Sector7.csv       combined_csv.csv
Sector2.csv       Sector5.csv       Sector8.csv

```
![Alt text](images/console.JPG?raw=true "Title")




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
* [financial finalizer setup](#financial-finalizer-setup)
* [console setup](#kubernetes-console-setup)

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
### frontend-setup

deploy the frontend for the bluetron dataprocessor engine.

```
$ kubectl apply -f https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/ui/bluetron-frontend.yaml

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


### financial-finalizer-setup

Deploy the financial processor using the below steps:

```
$ kubectl apply -f https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/financialfinalizer/bluetron-financial-finalizer.yaml

```

### kubernetes-console-setup

Rubn the below command to setup portainer kubernetes console where you can manage to give access to different users using internal auth to access resourcepool objects.

```
$ kubectl apply -f https://raw.githubusercontent.com/hackathon-bluetron/kubernetes-workflow-engine/master/console/console-install.yaml

```
