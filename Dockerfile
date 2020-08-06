FROM axiom/docker-luigi:2.8.13-alpine
COPY src/luigid-start.sh /bin/run.sh
COPY src/luigi.cfg /etc/luigi/luigi.cfg
RUN chmod +x /bin/run.sh
ENTRYPOINT ["/bin/run.sh"]
