FROM ubuntu:20.04

# ignore dialogue
ENV DEBIAN_FRONTEND=noninteractive

# upgrade env
RUN apt update
RUN apt upgrade -y

RUN apt install libmicrohttpd-dev -y
RUN apt install libjansson-dev -y
RUN apt install libssl-dev  libsofia-sip-ua-dev libglib2.0-dev -y
RUN apt install libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev -y
RUN apt install libconfig-dev pkg-config gengetopt libtool automake make -y
RUN apt install git -y
RUN apt install meson ninja-build
RUN apt install wget
RUN apt install cmake -y





# not listed but needed...
RUN apt install vim -y
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /home/share
WORKDIR /home
EXPOSE 8501



# ----------------------
# install libnice
# ----------------------
RUN git clone https://gitlab.freedesktop.org/libnice/libnice
WORKDIR /home/libnice
RUN meson --prefix=/usr --libdir=lib build
RUN ninja -C build
RUN ninja -C build install

# ----------------------
# install libsrtp
# ----------------------
WORKDIR /home
RUN wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz
RUN tar xfv v2.3.0.tar.gz
WORKDIR /home/libsrtp-2.3.0
RUN ./configure --prefix=/usr --enable-openssl
RUN make shared_library && make install

# ----------------------
# install libwebsockets
# ----------------------
RUN apt install cmake
WORKDIR /home
RUN git clone https://libwebsockets.org/repo/libwebsockets
WORKDIR /home/libwebsockets
RUN git checkout v3.2-stable
WORKDIR /home/libwebsockets/build
RUN cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
RUN make
RUN make install

# ----------------------
# install Janus
# ----------------------
WORKDIR /home
RUN git clone https://github.com/meetecho/janus-gateway.git
WORKDIR /home/janus-gateway
RUN ./autogen.sh
RUN ./configure --prefix=/opt/janus
RUN make
RUN make install
RUN make configs


# ----------------------
# install Nginx
# ----------------------
WORKDIR /home
RUN apt install nginx -y
WORKDIR /home/janus-gateway
RUN cp -a html/* /var/www/html

RUN service nginx start

# ----------------------
# exec Janus
# ----------------------
# WORKDIR /opt/janus
# RUN /opt/janus/bin/janus


# ----------------------
# ssl-cert
# ----------------------
RUN apt install ssl-cert
RUN make-ssl-cert generate-default-snakeoil



# ----------------------
# docker execute
# ----------------------
# docker build -t janus -f ./Dockerfile .
# docker run -itd -v /home/hostuser1/share:/home/share -p 8080:8080 --name janus-cont janus
# docker exec -it janus-cont /bin/bash
