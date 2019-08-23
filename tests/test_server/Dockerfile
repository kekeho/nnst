FROM nimlang/nim

COPY server.nim /
RUN nim c -d:release --threads:on -d:ssl server.nim

CMD [ "/server" ]