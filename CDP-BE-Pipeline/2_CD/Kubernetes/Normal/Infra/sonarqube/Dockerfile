FROM sonarqube:9.5.0-community

RUN adduser -u 99 -S -G root -H 666 && \
    chmod -R g+w ${SONARQUBE_HOME}

USER 666

ENTRYPOINT ["./bin/run.sh"]