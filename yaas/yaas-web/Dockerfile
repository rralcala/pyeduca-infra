FROM phusion/passenger-ruby19

ENV HOME /root
CMD ["/sbin/my_init"]
EXPOSE 80

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD rails-env.conf /etc/nginx/main.d/rails-env.conf
RUN rm /etc/apt/sources.list.d/redis.list
RUN apt-get remove -y openssh-server isc-dhcp-common isc-dhcp-client 
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get upgrade --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

RUN mkdir -p /var/yaas-web
ADD Gemfile /var/yaas-web/Gemfile

WORKDIR /var/yaas-web

RUN bundle install

ADD . /var/yaas-web
RUN chown -R app:app /var/yaas-web

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

