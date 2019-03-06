FROM puppet

# Copy the whole system except what is specified in .dockerignore
COPY /configs/ /usr/share/puppetcontent/configs/
COPY /lib/ /var/lib/puppet/

# Launch all services
CMD ["/usr/bin/ruby", "/usr/sbin/puppetmasterd", "--no-daemonize"]
