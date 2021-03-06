#!/bin/bash

set -euo pipefail

# The environment variable indicating the path to the FastRTPS configuration
export FASTRTPS_DEFAULT_PROFILES_FILE=/fastRTPS_profile/fastRTPS_profile_ds_listener.xml

# Grab the IP of the discovery server (if not provided) and fill the configuration
if [ -z "${DISCOVERY_SERVER_IP}" ]; then
    DISCOVERY_SERVER_IP=$(getent hosts "${DISCOVERY_SERVER_NAME}" | awk '{ print $1 ; exit }')
fi
sed -i "s/__DISCOVERY_SERVER_IP__/${DISCOVERY_SERVER_IP}/" ${FASTRTPS_DEFAULT_PROFILES_FILE}

# Grab the IP of the yolo service (if not provided) and fill the configuration
if [ -z "${YOLO_SERVICE_IP}" ]; then
    YOLO_SERVICE_IP=$(getent hosts "${YOLO_SERVICE_NAME}" | awk '{ print $1 ; exit }')
fi
sed -i "s/__YOLO_SERVICE_IP__/${YOLO_SERVICE_IP}/" ${FASTRTPS_DEFAULT_PROFILES_FILE}

# Source the ROS2 configuration file
. /opt/ros/darknet_ros_tiny/install/setup.bash

# Run the image publisher, replacing the current process to get signals
exec ros2 launch darknet_ros darknet_ros.launch.py
