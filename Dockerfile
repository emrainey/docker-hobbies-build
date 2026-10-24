FROM debian:stable-slim

# Update the package lists
RUN apt update
# Install timezone data to avoid tzdata prompt during build
RUN apt-get install -y tzdata locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV WS=/ws

# Add some common basic tools and
RUN apt install -y joe vim zsh tmux screen htop curl wget sudo openssl
# Add some developer tools
RUN apt install -y git cmake make ninja-build
# adds the Host compiler
RUN apt install -y clang-19 clangd-19 llvm-19 lld-19 lldb-19 libc++-19-dev libc++abi-19-dev libomp-dev
# Installs developer tools
RUN apt install -y lcov gcovr doxygen graphviz catch2 libgtest-dev libgmock-dev libbenchmark-dev valgrind cppcheck
# Adds the Verilog simulator used by the isa RTL tests
RUN apt install -y verilator && verilator --version
# Add Python3 and Pip3
RUN apt install -y python3 python3-pip python3-venv python3-setuptools python3-pybind11 python3-pytest python3-pytest-cov
# Add some libraries we need
RUN apt install -y ncurses-dev libopencv-dev libsdl2-dev libssl-dev
# Clean up unnecessary packages
RUN apt autoremove --purge -y && apt autoclean -y && rm -rf /var/cache/apt/* /tmp/*
# Set clang-19 as the default clang
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100
RUN update-alternatives --install /usr/bin/lld lld /usr/bin/lld-19 100
RUN update-alternatives --install /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-19 100
# Check each compiler
RUN clang --version && clang++ --version

# Create a non-root user and add as sudoer
RUN useradd -m -s /bin/zsh dev && echo "dev ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Create the workspace directory
RUN mkdir -p ${WS} && sudo chown dev:dev ${WS} && sudo chmod 777 ${WS}
# Define the working directory
WORKDIR ${WS}
# Switch to the non-root user
USER dev
# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

