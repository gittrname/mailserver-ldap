#!/bin/bash

#########################################
# Setup conf
#########################################

## Postfix ##

# Set LDAP conf: ldap_servers (ex: ldap://ldap)
if [ -n "$LDAP_SERVER" ]; then
        sed -i "s/^ldap_servers\s*:.*$/ldap_servers: $LDAP_SERVER/" /etc/postfix/saslauthd.conf
fi

# Set LDAP conf: ldap_bind_dn (ex: bind_dn=cn=admin, ou=users, dc=example, dc=org)
if [ -n "$LDAP_BIND_DN" ]; then
	sed -i "s/^ldap_bind_dn\s*:.*$/ldap_bind_dn: $LDAP_BIND_DN/" /etc/postfix/saslauthd.conf
fi

# Set LDAP conf: ldap_bind_pw
if [ -n "$LDAP_BIND_PW" ]; then
	sed -i "s/^ldap_password\s*:.*$/ldap_password: $LDAP_BIND_PW/" /etc/postfix/saslauthd.conf
fi

# Set LDAP conf: ldap_search_base (ex: base=dc=users, dc=example, dc=org)
if [ -n "$LDAP_BASE" ]; then
	sed -i "s/^ldap_search_base\s*:.*$/ldap_search_base: $LDAP_BASE/" /etc/postfix/saslauthd.conf
fi

# Set LDAP conf: ldap_filter (ex: uid=%u)
if [ -n "$LDAP_USER_FIELD" ]; then
	sed -i "s/^ldap_filter\s*:.*$/ldap_filter: ($LDAP_USER_FIELD=%u)/" /etc/postfix/saslauthd.conf
fi

# Set Postfix conf: virtual_mailbox_domains (ex: example.org)
if [ -n "$DOMAIN" ]; then
	sed -i "s/^virtual_mailbox_domains\s*=.*$/virtual_mailbox_domains = $DOMAIN/" /etc/postfix/main.cf
fi

# Set Postfix conf: hostname (ex: smtp.example.org)
if [ -n "$HOSTNAME" ]; then
	sed -i "s/^myhostname\s*=.*$/myhostname = $HOSTNAME/" /etc/postfix/main.cf
fi


## Dovecot ##

# Set LDAP conf: hosts (ex: ldap://ldap)
if [ -n "$LDAP_SERVER" ]; then
        sed -i "s/^hosts\s*:.*$/hosts: $LDAP_SERVER/" /etc/dovecot/dovecot-ldap.conf.ext
fi

# Set LDAP conf: base (ex: base=dc=mail, dc=example, dc=org)
if [ -n "$LDAP_BASE" ]; then
	sed -i "s/^\s*base\s*=.*$/base=$LDAP_BASE/g" /etc/dovecot/dovecot-ldap.conf.ext
fi

# Set LDAP conf: user_filter and pass_filter (ex: user_filter = (uid=%n))
if [ -n "$LDAP_USER_FIELD" ]; then
	sed -i "s/^\s*user_filter\s*=.*$/user_filter=($LDAP_USER_FIELD=%n)/g" /etc/dovecot/dovecot-ldap.conf.ext
	sed -i "s/^\s*pass_filter\s*=.*$/pass_filter=($LDAP_USER_FIELD=%n)/g" /etc/dovecot/dovecot-ldap.conf.ext
fi

# Set LDAP conf: pass_attrs (ex: pass_attrs = uid=user,userPassword=password)
if [ -n "$LDAP_USER_FIELD" ]; then
	sed -i "s/^\s*pass_attrs\s*=.*$/pass_attrs=$LDAP_USER_FIELD=user/g" /etc/dovecot/dovecot-ldap.conf.ext
fi


#########################################
# Generate SSL certification
#########################################

CERT_FOLDER="/etc/ssl/localcerts"
KEY_PATH="$CERT_FOLDER/mail.key.pem"
CSR_PATH="$CERT_FOLDER/mail.csr.pem"
CERT_PATH="$CERT_FOLDER/mail.cert.pem"

if [ ! -f $CERT_PATH ] || [ ! -f $KEY_PATH ]; then
	mkdir -p $CERT_FOLDER

    echo "SSL Key or certificate not found. Generating self-signed certificates"
    openssl genrsa -out $KEY_PATH

    openssl req -new -key $KEY_PATH -out $CSR_PATH \
    -subj "/CN=mail"

    openssl x509 -req -days 3650 -in $CSR_PATH -signkey $KEY_PATH -out $CERT_PATH
fi



#############################################
# Add dependencies into the chrooted folder
#############################################

echo "Adding host configurations into postfix jail"
rm -rf /var/spool/postfix/etc
mkdir -p /var/spool/postfix/etc
cp -v /etc/hosts /var/spool/postfix/etc/hosts
cp -v /etc/services /var/spool/postfix/etc/services
cp -v /etc/resolv.conf /var/spool/postfix/etc/resolv.conf
echo "Adding name resolution tools into postfix jail"
rm -rf "/var/spool/postfix/lib"
mkdir -p "/var/spool/postfix/lib/$(uname -m)-linux-gnu"
cp -v /lib/$(uname -m)-linux-gnu/libnss_* "/var/spool/postfix/lib/$(uname -m)-linux-gnu/"



#########################################
# Start services
#########################################

function services {
	echo ""
	echo "#########################################"
	echo "$1 rsyslog"
	echo "#########################################"
	service rsyslog $1

	echo ""
	echo "#########################################"
	echo "$1 SASL"
	echo "#########################################"
	service saslauthd $1

	echo ""
	echo "#########################################"
	echo "$1 Postfix"
	echo "#########################################"
	postfix $1

	echo ""
	echo "#########################################"
	echo "$1 Dovecot"
	echo "#########################################"
	service dovecot $1
}

# Set signal handlers
trap "services stop; exit 0" SIGINT SIGTERM
trap "services reload" SIGHUP

# Start services
services start

# Redirect logs to stdout
tail -F "/var/log/mail.log" &
wait $!
