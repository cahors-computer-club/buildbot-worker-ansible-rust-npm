FROM        buildbot/buildbot-worker:latest
MAINTAINER  OPUS Solutions

USER root

RUN mkdir /rust && mkdir /cargo && chown buildbot:buildbot /rust /cargo

RUN echo "(curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly --no-modify-path) && rustup default nightly" > /install-rust.sh && chmod 755 /install-rust.sh

RUN apt install -y python3-pip

RUN pip3 install --upgrade cffi && \
    pip3 install --upgrade ansible && \
    pip3 install --upgrade pycrypto pywinrm \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

USER buildbot
WORKDIR /buildbot
 
ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo
ENV PATH=/cargo/bin:/rust/bin:$PATH
 
RUN /install-rust.sh && rustup component add clippy-preview && cargo install grcov
