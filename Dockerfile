From debian:latest
#MAINTAINER Timothée Eid <timothee.eid@erizo.fr>
MAINTAINER ペール<txgfx504@yahoo.co.jp>

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive
ENV HTTP_RPOXY $http_proxy
ENV HTTPS_PROXY $https_proxy

# Setup startup script
ADD entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

#######################################
#
# Postfix Settings
#
#######################################
# SMTP (Plain)
EXPOSE 25
# SMTP (StartSSL)
EXPOSE 587
# SMTP (SSL)
EXPOSE 465

VOLUME /var/spool/postfix
VOLUME /etc/ssl/localcerts
VOLUME /etc/postfix

# Install postfix
RUN apt-get update && apt-get install -y \
	openssl \
	rsyslog \
	postfix \
&& rm -rf /var/lib/apt/lists/*

# Add postfix conf
ADD postfix_conf /etc/postfix
RUN chmod 600 -R /etc/postfix

########################################
#
# Dovecot Settings
#
########################################
# IMAPs port
EXPOSE 993
# IMAP port
EXPOSE 143
# POPs port
EXPOSE 995
# POP port
EXPOSE 110
# ManageSieve port
EXPOSE 4190

VOLUME /var/mail
VOLUME /etc/ssl/localcerts
VOLUME /etc/dovecot

# Install dovecot
RUN apt-get update && apt-get install -y \
	openssl \
	dovecot-imapd \
	dovecot-lmtpd \
	dovecot-ldap \
	dovecot-sieve \
	dovecot-managesieved \
&& rm -rf /var/lib/apt/lists/*

# Add default conf
ADD default_conf /etc/dovecot

