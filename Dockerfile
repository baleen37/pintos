FROM ubuntu:16.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninterative \
        apt-get install -y --no-install-recommends \
            curl \
            tar \ 
            ca-certificates

WORKDIR /tmp
RUN curl -o pintos.tar.gz -L https://www.stanford.edu/class/cs140/projects/pintos/pintos.tar.gz
RUN tar -xzf pintos.tar.gz && \
    mv ./pintos/src /pintos && \
    rm -rf ./pintos.tar.gz ./pintos
WORKDIR /pintos

RUN apt-get update && \
    DEBIAN_FRONTEND=noninterative \
        apt-get install -y --no-install-recommends \
            coreutils \
			manpages-dev \
            xorg openbox \
            ncurses-dev \
            wget \
            vim emacs \
            gcc clang make \
            gdb ddd \
            qemu

RUN apt-get clean autoclean && \
    rm -rf /var/lib/apt/* /var/lib/cache/* /var/lib/log/*

ENV PATH=/pintos/utils:$PATH

RUN sed -i '/serial_flush ();/a \
  outw( 0x604, 0x0 | 0x2000 );' /pintos/devices/shutdown.c

RUN sed -i 's/bochs/qemu/' /pintos/*/Make.vars
RUN cd /pintos/threads && make
RUN sed -i 's/\/usr\/class\/cs140\/pintos\/pintos\/src/\/pintos/' /pintos/utils/pintos-gdb && \
    sed -i 's/LDFLAGS/LDLIBS/' /pintos/utils/Makefile && \
    sed -i 's/\$sim = "bochs"/$sim = "qemu"/' /pintos/utils/pintos && \
    sed -i 's/kernel.bin/\/pintos\/threads\/build\/kernel.bin/' /pintos/utils/pintos && \
    sed -i "s/my (@cmd) = ('qemu');/my (@cmd) = ('qemu-system-x86_64');/" /pintos/utils/pintos && \
    sed -i 's/loader.bin/\/pintos\/threads\/build\/loader.bin/' /pintos/utils/Pintos.pm

CMD ["sleep", "infinity"]
