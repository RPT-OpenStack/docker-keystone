FROM ubuntu/apache2:2.4-22.04_edge

# Will need to do this in future once Dalmation is no longer the latest release.
# RUN apt update
# RUN apt install software-properties-common -y
# RUN add-apt-repository cloud-archive:dalmatian

RUN apt-get update
RUN apt install keystone -y

# Run Apache as Keystone user, so change log ownership.
RUN chown -R keystone:keystone /var/log/apache2
RUN chown -R keystone:keystone /var/run/apache2

USER keystone
