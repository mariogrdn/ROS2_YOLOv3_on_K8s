ARG FROM_IMAGE=ros:foxy
ARG OVERLAY_WS=/opt/ros/darknet_ros_tiny

# multi-stage for caching
FROM $FROM_IMAGE AS cacher

# clone overlay source
ARG OVERLAY_WS
WORKDIR $OVERLAY_WS/src
RUN apt-get update && apt-get install -y wget \
 && git clone --single-branch --recursive --branch foxy https://github.com/mariogrdn/darknet_ros_tiny.git \ 
 && cd ./darknet_ros_tiny \
 && sed -i "s/OPENCV=0/OPENCV=1/g" ./darknet/Makefile \
 && sed -i "s/OPENMP=0/OPENMP=1/g" ./darknet/Makefile \
 && cd ./darknet_ros/yolo_network_config \
 && mkdir weights && cd ./weights \
 && wget https://github.com/dog-qiuqiu/Yolo-Fastest/raw/master/Yolo-Fastest/VOC/yolo-fastest.weights

# copy manifests for caching
WORKDIR /opt
RUN mkdir -p /tmp/opt && \
    find ./ -name "package.xml" | \
      xargs cp --parents -t /tmp/opt && \
    find ./ -name "COLCON_IGNORE" | \
      xargs cp --parents -t /tmp/opt || true

# multi-stage for building
FROM $FROM_IMAGE AS builder

# install overlay dependencies
ARG OVERLAY_WS
WORKDIR $OVERLAY_WS
COPY --from=cacher /tmp/$OVERLAY_WS/src ./src
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    apt-get update && rosdep install -y \
      --from-paths \
        src/darknet_ros_tiny \
      --ignore-src \
    && rm -rf /var/lib/apt/lists/*

# build overlay source
COPY --from=cacher $OVERLAY_WS/src ./src
ARG OVERLAY_MIXINS="release"
RUN apt-get update && apt-get install -y libx11-dev \
&& rm -rf /var/lib/apt/lists/*
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release \
      --packages-select \
        darknet_ros \
        darknet_ros_msgs \
      --mixin $OVERLAY_MIXINS

# source entrypoint setup
ENV OVERLAY_WS $OVERLAY_WS
RUN sed --in-place --expression \
      '$isource "$OVERLAY_WS/install/setup.bash"' \
      /ros_entrypoint.sh
RUN mkdir /fastRTPS_profile
COPY fastRTPS_profile_ds_listener.xml /fastRTPS_profile
COPY yolo_entrypoint.sh ./
RUN chmod +x ./yolo_entrypoint.sh

ENTRYPOINT ./yolo_entrypoint.sh
