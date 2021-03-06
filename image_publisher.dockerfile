ARG FROM_IMAGE=ros:foxy
ARG OVERLAY_WS=/opt/ros/image_pipeline

# multi-stage for caching
FROM $FROM_IMAGE AS cacher

# clone overlay source
ARG OVERLAY_WS
WORKDIR $OVERLAY_WS/src
RUN apt-get update && apt-get install -y wget \
 && git clone --single-branch --recursive --branch ros2 https://github.com/ros-perception/image_pipeline.git \ 
 && cd ./image_pipeline

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
        src/image_pipeline \
      --ignore-src \
    && rm -rf /var/lib/apt/lists/*

# build overlay source
COPY --from=cacher $OVERLAY_WS/src ./src
ARG OVERLAY_MIXINS="release"
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
    colcon build --mixin $OVERLAY_MIXINS

# source entrypoint setup
ENV OVERLAY_WS $OVERLAY_WS
RUN sed --in-place --expression \
      '$isource "$OVERLAY_WS/install/setup.bash"' \
      /ros_entrypoint.sh
RUN mkdir /fastRTPS_profile
COPY fastRTPS_profile_ds_talker.xml /fastRTPS_profile
COPY pub_entrypoint.sh ./
RUN chmod +x ./pub_entrypoint.sh

ENTRYPOINT ./pub_entrypoint.sh