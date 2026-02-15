FROM postgres:16-bookworm

RUN apt-get update &&  \ 
  apt-get -y install postgresql-16-cron && \ 
  apt-get clean && \ 
  rm -rf /var/lib/apt/lists/*
