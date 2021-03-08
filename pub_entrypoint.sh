#!/bin/bash

set -eo pipefail

# The environment variable indicating the path to the FastRTPS configuration
export FASTRTPS_DEFAULT_PROFILES_FILE=/fastRTPS_profile/fastRTPS_profile_ds_talker.xml

# Grab the IP of the discovery server (if not provided) and fill the configuration
if [ -z "${DISCOVERY_SERVER_IP}" ]; then
    DISCOVERY_SERVER_IP=$(getent hosts "${DISCOVERY_SERVER_NAME}" | awk '{ print $1 ; exit }')
fi
sed -i "s/__DISCOVERY_SERVER_IP__/${DISCOVERY_SERVER_IP}/" ${FASTRTPS_DEFAULT_PROFILES_FILE}

# Source the ROS2 configuration file
. /opt/ros/image_pipeline/install/setup.bash

# Run the image publisher, replacing the current process to get signals
exec ros2 run image_publisher image_publisher_node "${VIDEO_PATH}"
