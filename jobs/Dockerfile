FROM ubuntu

RUN apt-get update && apt-get install -y mysql-client python3-pip

RUN pip3 install awscli boto3

COPY leases.py /