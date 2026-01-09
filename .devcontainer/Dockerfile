# Use Ubuntu as base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    make \
    unzip \
    libncurses5 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create ada user with sudo privileges
RUN useradd -m -s /bin/bash ada && \
    echo "ada ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up working directory
WORKDIR /opt

# Download and install ARM GCC toolchain for embedded
RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    tar xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    rm arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz && \
    mv arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi /opt/arm-gcc

# Add ARM GCC to PATH
ENV PATH="/opt/arm-gcc/bin:${PATH}"

# GNAT ARM ELF will be installed by Alire in the user setup below
# No manual installation needed

# Install GPRbuild and additional Ada tools via Alire
RUN wget -q https://github.com/alire-project/alire/releases/download/v2.1.0/alr-2.1.0-bin-x86_64-linux.zip && \
    unzip -q alr-2.1.0-bin-x86_64-linux.zip && \
    mv bin/alr /usr/local/bin/ && \
    rm -rf bin alr-2.1.0-bin-x86_64-linux.zip

# Install Python packages for SVD generation
RUN pip3 install --no-cache-dir \
    pyyaml \
    jinja2 \
    lxml

# Clone svd2ada tool (will be built in post-create script after gprbuild is available)
RUN git clone --depth 1 https://github.com/AdaCore/svd2ada.git /opt/svd2ada

# Add svd2ada to PATH
ENV PATH="/opt/svd2ada:${PATH}"

# Clone CMSIS-SVD repository for STM32 SVD files
RUN git clone --depth 1 https://github.com/posborne/cmsis-svd.git /opt/cmsis-svd

# Set up environment variables
ENV CMSIS_SVD_PATH=/opt/cmsis-svd
ENV SVD2ADA_PATH=/opt/svd2ada

# Switch to ada user
USER ada
WORKDIR /workspace

# Configure alire for the ada user and install toolchain
RUN alr config --global --set user.name "Ada Developer" && \
    alr config --global --set user.email "dev@example.com" && \
    alr toolchain --select gnat_arm_elf gprbuild

# Keep container running - VS Code will override this
CMD ["sleep", "infinity"]
