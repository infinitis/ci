FROM debian:latest

RUN apt-get update
RUN apt-get install -y git gitweb fcgiwrap nginx-light cron

RUN adduser --disabled-password --gecos "" git
WORKDIR /repos
RUN chown git:git /repos

COPY crontab /etc/cron.d/git-cron
RUN chmod 0644 /etc/cron.d/git-cron
RUN crontab -u git /etc/cron.d/git-cron

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY clone.sh /clone.sh

CMD /entrypoint.sh