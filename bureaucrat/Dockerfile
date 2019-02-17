FROM python:3-slim

COPY ./server.py /usr/src/app/
COPY ./sig01 /usr/src/app/
COPY Dockerfile /

WORKDIR /usr/src/app

CMD ["/usr/local/bin/python3", "./server.py"]
