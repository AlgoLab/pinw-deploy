FROM phusion/passenger-ruby22:0.9.19

# Set correct environment variables.
ENV HOME /root
# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Enable nginx + passenger
RUN rm -f /etc/service/nginx/down
ARG CACHEBUST=1
RUN apt-get update
RUN apt-get -y install sqlite3 python
RUN apt-get -y upgrade

# Get PInW
USER app
WORKDIR /home/app
RUN echo "source /etc/profile" >> ~/.bashrc

RUN git clone https://github.com/AlgoLab/pinw
RUN mkdir /home/app/data
WORKDIR /home/app/pinw
ENV RACK_ENV production

USER root
RUN setuser app bundle install

USER app
WORKDIR /home/app/pinw
RUN rake db:setup
COPY pinw.db /home/app/data/db/pinw.db
RUN whenever -w
# New crontab:
USER root
COPY crontab /etc/crontab
COPY update-pinw.sh /usr/local/bin/update_pinw.sh

# Add configuration to nginx:
USER root
RUN rm /etc/nginx/sites-enabled/default
COPY nginx-pinw.conf /etc/nginx/sites-enabled/pinw.conf

COPY init-ssh.sh /etc/my_init.d/init-ssh.sh
EXPOSE 80


