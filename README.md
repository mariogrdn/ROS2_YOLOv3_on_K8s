# YOLOv3 on ROS2 on Kubernetes

In this repository is presented a ROS2 system (running on top of Kubernetes) executing a very lightweight instance of YOLOv3 (https://pjreddie.com/darknet/yolo), a real-time object recognition application.
The ROS2 version of YOLOv3 used in the respective Docker images can be found at https://github.com/mariogrdn/darknet_ros_tiny.
The Dockerfile and the code related to the operator is available at https://github.com/mariogrdn/network_operator.
The base noVNC Docker image that has been used for the image_viewer is available at https://github.com/ConSol/docker-headless-vnc-container.

All the images are already available on Docker Hub, but if the necessity arises to build them anew, the Dockerfiles are provided. If that is the case, it is important to remember to edit the YAML files in order to make them use the correct image.

# Prerequisites

Two running Kubernetes clusters federated by means of Liqo, which provides guides on how to install it on your cluster on the page https://doc.liqo.io.
An example ForeignCluster resource definition is provided in this repository. 
This work has been tested with two K3s clusters running onto two separate machines in the same LAN and with two Kind clusters running on the same machine.
In alternative, a single cluster can be used, therefore getting rid of the necessity of federating the clusters, but this requires to change the nodeAffinity into yolo_tiny_deployment_remote, in order to allow Kubernetes to properly schedule it.

# How To Use

Before deploying the resources, it is necessary to customize the operator and the remote YOLO yaml. In the former we need to set the environment variable "NETCARD" to the name of the wireless card available on the host (if there is none, the operator will not work, therefore must not be deployed), in the latter we need to manually set the environment variable "YOLO_SERVICE_IP" to the IP of the "yolo_service" Kubernetes service.
In particular:
  - In case of federated clusters, it is important that this IP corresponds to the IP of the service running in the local cluster (the one hosting the image publisher, the image viewer, the discovery server and the YOLO local node).
  - In case it is deployed onto a single cluster, the "YOLO_SERVICE_IP" environment variable can be commented out in the YAML file.
In order to use it is necessary to simply apply all the resource to your cluster by means of "kubectl apply -f <yamlFile>".
It is mandatory to firstly deploy "service.yml" (especially because the IP address of yolo_service is needed to properly configure the YOLO remote deployment) and the Discovery Server.
As soon as it is up and running, it is possible to deploy all the other resources.

As soon as the image viewer pod is running, we can open a browser and navigate to "localhost:32001", we will get to a noVNC login page. The password is "headless". After that, a Xubuntu desktop environment will be available to use. Open a terminal and execute "view_entrypoint.sh". This will start the ROS2 image viewer node allowing us to see the detection performed by the YOLO node exposed at that moment by the Kubernetes service "yolo_service".

The deployed operator is responsible of modifying the Selector field of "yolo_service" based on the network status:
  - If the network connectivity is good, the selector will be set to "remote", meaning that the remote instance of YOLO will be used.
  - If the network connectiivty is bad or completely absent, the selector will be set to "local", meaning that the local instance of YOLO will be used.
It also has an hysteresis time, preventing too many changes to happen in a short amount of time in case the network is particularly unstable.

# Expected Results

It is expected that, no matter what the network connectivy status is, the system will always fallback to the most appropriate YOLO instance and therefore will always be able to perform object recognition.
