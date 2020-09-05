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
To run this project, install it locally using npm:

```
$ cd ../lorem
$ npm install
$ npm start
```

### openebs-setup
To setup the openebs as storage class provisioner and automating volume provisioning follow the instructions below.
