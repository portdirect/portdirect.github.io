FROM debian:buster-slim
RUN apt-get update ;\
    apt-get install -y curl ;\
    curl -o /tmp/hugo.deb -sSL https://github.com/gohugoio/hugo/releases/download/v0.62.0/hugo_0.62.0_Linux-64bit.deb ;\
    dpkg --install /tmp/hugo.deb ;\
    rm -f /tmp/hugo.deb

