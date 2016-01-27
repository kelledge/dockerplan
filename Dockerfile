FROM debian:jessie

# Instruct dpkg and debconf to be quiet
ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Grab cross toolchain
RUN echo 'deb http://emdebian.org/tools/debian/ jessie main' > /etc/apt/sources.list.d/crosstools.list
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 7DE089671804772E
RUN dpkg --add-architecture armhf

# Grab the needed build tools
RUN apt-get -yq update && \
    apt-get -yq install build-essential devscripts debhelper ccache curl git-core \
                        crossbuild-essential-armhf qemu-user

# Enable the compiler cache by default. If you need to disable ccache, 
# just set the CCACHE_DISABLE environment variable
RUN mkdir -p /var/cache/ccache
ENV PATH=/usr/lib/ccache:/bin:/sbin:/usr/bin:/usr/sbin
ENV CCACHE_UMASK=002 CCACHE_COMPRESS=1 CCACHE_DIR=/var/cache/ccache
