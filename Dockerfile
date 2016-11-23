FROM centos:latest
MAINTAINER Nathon Fowlie <nathon.fowlie@gmail.com>

WORKDIR /tmp

COPY install.sh install.sh
COPY directives.adoc directives.adoc

USER root
RUN chmod a+x install.sh && \
    /bin/bash ./install.sh -v 8u66

ENV IMOD=/tmp/imod/IMOD
ENV RUNCMD_VERBOSE=1
ENV IMOD_DIR=$IMOD
ENV PATH=$PATH:$IMOD_DIR$IMOD_DIR/bin
ENV MANPATH=$IMOD/man
ENV IMOD_JAVADIR=/usr/java
ENV IMOD_PLUGIN_DIR=$IMOD/lib/imodplug
ENV LD_LIBRARY_PATH=$IMOD/lib/
ENV FOR_DISABLE_STACK_TRACE=1
ENV IMOD_QTLIBDIR=$IMOD/qtlib

