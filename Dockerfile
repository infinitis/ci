FROM debian:latest

RUN apt-get update
RUN apt-get install -y git git-daemon-run nginx-light

USER git

USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh