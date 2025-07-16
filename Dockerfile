FROM debian:12
RUN apt update && apt upgrade -y
RUN apt install -y build-essential nasm gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu \
	  gcc-mips-linux-gnu gcc-mips64-linux-gnuabi64 \gcc-mips64el-linux-gnuabi64 gcc-mipsel-linux-gnu \
		gcc-riscv64-linux-gnu gcc-x86-64-linux-gnu \
		vim iproute2 strace netcat-traditional git \
		binfmt-support qemu-user-static \
		procps  lsof net-tools


		
RUN git clone https://git.savannah.nongnu.org/git/netkitty.git
RUN cd netkitty && make && make install && cd .. && rm -Rf netkitty

