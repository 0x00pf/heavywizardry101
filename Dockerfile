FROM debian:12
RUN apt update && apt upgrade -y
RUN apt install -y build-essential nasm gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu \
	  gcc-mips-linux-gnu gcc-mips64-linux-gnuabi64 \gcc-mips64el-linux-gnuabi64 gcc-mipsel-linux-gnu \
		gcc-riscv64-linux-gnu gcc-x86-64-linux-gnu \
		vim iproute2 strace netcat-traditional git \
		binfmt-support qemu-user-static file \
		procps  lsof net-tools

# Enable execution of dynamic binaries
run mkdir /etc/qemu-binfmt
run ln -s /usr/x86_64-linux-gnu /etc/qemu-binfmt/x86_64
run ln -s /usr/mips-linux-gnu/ /etc/qemu-binfmt/mips
run ln -s /usr/arm-linux-gnueabi/ /etc/qemu-binfmt/arm
run ln -s /usr/riscv64-linux-gnu/ /etc/qemu-binfmt/riscv64
run ln -s /usr/aarch64-linux-gnu/ /etc/qemu-binfmt/aarch64

RUN git clone https://git.savannah.nongnu.org/git/netkitty.git
RUN cd netkitty && make && make install && cd .. && rm -Rf netkitty

