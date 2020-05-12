FROM amazonlinux:latest
ARG PY_VER
ENV PY_VER ${PY_VER:-2.7.0}
RUN echo $PY_VER
WORKDIR /app

# install pip.
RUN curl -s https://bootstrap.pypa.io/get-pip.py | python

# requirements for compiling packages.
RUN yum install -y \
  gcc \
  gcc-gfortran \
  lapack-devel \
  gcc-c++ \
  findutils \
  python-devel.x86_64 \
  make \
  zlib-devel \
  git \
  tar.x86_64 \
  openssl \
  openssl-devel \
  bzip2 \
  bzip2-devel \
  readline-devel \
  libffi-devel \
  sqlite \
  sqlite-devel

# install python dependencies.
COPY requirements.txt .
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/:$PKG_CONFIG_PATH

# pyenv - repo: https://github.com/pyenv/pyenv/blob/master/README.md
# pyenv lets you easily switch between multiple versions of Python.
# Install pyenv (Python Version Management).
WORKDIR /root
RUN git clone git://github.com/yyuu/pyenv.git .pyenv
ENV HOME  /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Execute install python script
COPY ./install_python.sh .
RUN chmod +x ./install_python.sh
RUN ./install_python.sh -v=$PY_VER

# Upgrade pip setuptools.
WORKDIR /app
RUN python -V
RUN pip install -U setuptools

# numpy needs to be installed globally as few packages
# checks the regular path for numpy as a requirement.
RUN pip install numpy
RUN pip install --no-cache-dir -r requirements.txt -t ./lib
