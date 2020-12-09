FROM        buildbot/buildbot-worker:v2.8.4
MAINTAINER  OPUS Solutions

USER root

RUN mkdir /rust && mkdir /cargo && chown buildbot:buildbot /rust /cargo

RUN echo "(curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly --no-modify-path) && rustup default nightly" > /install-rust.sh && chmod 755 /install-rust.sh

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt update -y && apt install -y clang python3 python3-pip libssl-dev libssl1.1 openssl pkg-config libsqlite3-0 libsqlite3-dev zip wget git-lfs afl clang llvm

RUN pip3 install --upgrade cffi && \
    pip3 install --upgrade ansible && \
    pip3 install --upgrade pycrypto pywinrm && \
    pip3 install --upgrade hvac && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt install -y nodejs

RUN cd /tmp ; wget https://releases.hashicorp.com/vault/1.4.2/vault_1.4.2_linux_amd64.zip -O vault.zip && \
	unzip vault.zip && \
	mv vault /usr/bin/vault && \
	chmod +x /usr/bin/vault

USER buildbot
WORKDIR /buildbot
RUN git lfs install
        
RUN ansible-galaxy collection install community.general
 
ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo
ENV PATH=/cargo/bin:/rust/bin:$PATH


RUN /install-rust.sh && rustup component add clippy-preview
RUN rustup default nightly
# # Add debug
RUN cargo install grcov
RUN cargo install sccache
