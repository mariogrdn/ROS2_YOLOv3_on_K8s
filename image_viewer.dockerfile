FROM accetto/ubuntu-vnc-xfce-g3:vnc-novnc
ENV REFRESHED_AT 2018-03-18

# Switch to root user to install additional software
USER 0

# Install necessary software
RUN mkdir /fastRTPS_profile
COPY fastRTPS_profile_ds_talker.xml /fastRTPS_profile
COPY view_entrypoint.sh ./
RUN chmod +x ./view_entrypoint.sh

RUN apt-get update && apt-get install -y --no-install-recommends locales \
&& locale-gen en_US en_US.UTF-8 \
&& update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
&& export LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends curl \
gnupg2 \
git \
lsb-release \
&& curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
&& sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
&& apt-get update && apt-get install -y --no-install-recommends ros-foxy-ros-base

RUN git clone --single-branch --branch ros2 https://github.com/ros-perception/image_pipeline.git \
&& cd ./image_pipeline \
&& apt-get install -y --no-install-recommends python3-colcon-common-extensions \
python3-pip \
make \
g++ \
&& pip3 install -U rosdep && rosdep init && rosdep fix-permissions && rosdep update --rosdistro foxy && rosdep install --rosdistro foxy -y --from-path . \
&& . /opt/ros/foxy/setup.sh && colcon build \
&& . ./install/setup.sh



