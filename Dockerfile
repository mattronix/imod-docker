FROM nathonfowlie/centos-jre
MAINTAINER Kevin Savage


COPY installImod.sh installImod.sh

USER root
RUN chmod a+x installImod.sh && \
    /bin/bash ./installImod.sh -v 8u66

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

