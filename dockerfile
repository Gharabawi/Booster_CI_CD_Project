FROM ubuntu
USER root
COPY simpleApp /simpleApp
COPY manage.py /manage.py
COPY requirements.txt /requirements.txt
WORKDIR /
RUN apt-get update -qq
RUN apt-get install python3.6 -qq
RUN apt-get install python3-pip -qq
CMD pip3 install -r requirements.txt; python3 manage.py makemigrations; python3 manage.py migrate; python3 manage.py runserver 0.0.0.0:8000;/bin/bash
