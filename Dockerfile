
#use centos-jre as a base image for our application.

FROM nathonfowlie/centos-jre
MAINTAINER Kevin Savage

USER root

# Install Dependencies 
RUN yum install -y \
tcsh \
file \
libjpeg \
freetype \
libSM \
libXi \
libXrender \
libXrandr \
libXfixes \
libXcursor \
libXinerama \
fontconfig

# Download imod
RUN curl --progress-bar --connect-timeout 30 --junk-session-cookies --insecure --location --max-time 3600 --retry 3 --retry-delay 60 "http://bio3d.colorado.edu/imod/AMD64-RHEL5/imod_4.7.15_RHEL7-64_CUDA6.5.csh" --output "imod_4.7.15_RHEL7-64_CUDA6.5.csh" 

# create imod directoy 
RUN mkdir imod \
&& mkdir scripts \
&& tcsh -f imod_4.7.15_RHEL7-64_CUDA6.5.csh -script scripts -dir imod -yes 

# setup environment variables
ENV IMOD=/tmp/imod/IMOD
ENV RUNCMD_VERBOSE=1
ENV IMOD_DIR=$IMOD
ENV PATH=$PATH:$IMOD_DIR:$IMOD_DIR/bin
ENV MANPATH=$IMOD/man
ENV IMOD_JAVADIR=/usr/java
ENV IMOD_PLUGIN_DIR=$IMOD/lib/imodplug
ENV LD_LIBRARY_PATH=$IMOD/lib/
ENV FOR_DISABLE_STACK_TRACE=1
ENV IMOD_QTLIBDIR=$IMOD/qtlib





