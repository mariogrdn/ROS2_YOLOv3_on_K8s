# YOLOv3 on ROS2 on Kubernetes

In this repository is presented a ROS2 system (running on top of Kubernetes) executing a very lightweight instance of YOLOv3 (https://pjreddie.com/darknet/yolo), a real-time object recognition application.
The ROS2 version of YOLOv3 used in the respective Docker images can be found at https://github.com/mariogrdn/darknet_ros_tiny.
The Dockerfile and the code related to the operator is available at https://github.com/mariogrdn/network_operator.
The base noVNC Docker image that has been used for the image_viewer is available at https://github.com/ConSol/docker-headless-vnc-container.

All the images are already available on Docker Hub, but if the necessity arises to build them anew, the Dockerfiles are provided. If that is the case, it is important to remember to edit the YAML files in order to make them use the correct image.

# Prerequisites

Two running Kubernetes clusters federated by means of Liqo (doc.liqo.io).
In alternative, a single cluster can be used, therefore getting rid of the necessity of federating the clusters, but this requires to change the nodeAffinity into 
