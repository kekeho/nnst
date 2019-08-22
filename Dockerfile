FROM nimlang/nim

COPY ./ /project

WORKDIR /project

RUN nimble install

CMD [ "./nnst" ]
