#
#Base image Ubuntu 20.04 "Focal"

FROM ubuntu:focal AS prep

#
#Maintainer label

LABEL maintainer="mariogrdn@gmail.com"

#
#Set necessary env

ENV TZ Europe/Rome

#
#Install all the necessary dependencies and softwares

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && apt-get update && apt-get install -y \
 cmake \
 g++ \
 python3-pip \
 wget \
 git \
 libasio-dev \
 libtinyxml2-dev \
 libssl-dev \
 && pip3 install -U colcon-common-extensions vcstool \
 && rm -rf /var/lib/apt/lists/* 
 
#
#Download the sources
RUN mkdir /source \
 && mkdir /build \
 && cd /source \
 && vcs import --input https://raw.githubusercontent.com/mariogrdn/Discovery-Server/master/discovery-server.repos 
 
#
#Build the server
RUN cd /build \
 && colcon build --base-paths /source --packages-up-to discovery-server --cmake-args -DTHIRDPARTY=ON -DCOMPILE_EXAMPLES=ON -DLOG_LEVEL_INFO=ON -DCMAKE_BUILD_TYPE=Release \
 && rm -rf /source
  
#
#Copy only what is necessary
FROM ubuntu:focal
ENV CONFIG_XML_PATH /fastRTPS_profile/fastRTPS_profile_ds.xml
COPY --from=prep /build /build
COPY discovery_entrypoint.sh /
RUN mkdir /fastRTPS_profile
COPY fastRTPS_profile_ds.xml /fastRTPS_profile

RUN chmod +x /discovery_entrypoint.sh \
 && apt-get update && apt-get install -y python3   

#
#Run the server
ENTRYPOINT ./discovery_entrypoint.sh

ENTRYPOINT /discovery_entrypoint.sh

