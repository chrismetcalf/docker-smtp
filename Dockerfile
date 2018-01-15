FROM debian:jessie

MAINTAINER Oluwaseun Obajobi "oluwaseun.obajobi@namshi.com"

RUN apt-get update && \
    apt-get install -y exim4-daemon-light ripmime && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

COPY entrypoint.sh /bin/
COPY ripmail.sh /bin/
COPY set-exim4-update-conf /bin/

RUN chmod a+x /bin/entrypoint.sh && \
    chmod a+x /bin/set-exim4-update-conf && \
    chmod a+x /bin/ripmail.sh 

EXPOSE 25
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["exim", "-bd", "-q15m", "-v"]
