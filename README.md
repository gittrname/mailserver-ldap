<<<<<<< HEAD
Docker postfix-ldap
===================

A Docker image running Postfix on Debian stable ("jessie" at the moment) with the LDAP backend (using bind auth)

The Postfix is configured to :
* Relay incoming mails going to `$DOMAIN` to the `mda` host using the `LMTP` protocol. (MDA: Mail Delivery Agent)
* Relay outgoing mails to other domains only if the user is authenticated (using `LDAP` backend)
=======
Docker dovecot-ldap
===================

A Docker image running Dovecot on Debian stable ("jessie" at the moment) with the following modules:
* LMTP
* LDAP backend (with bind auth)

This image provide mailbox managment services. You can access those mailboxes using `IMAP` or `POP` protocols. Mails might be delivered using `LMTP` protocol.

Every mailbox access required an authenticated user.
The user database is provided by an external LDAP service.
>>>>>>> dovecot-ldap/master

Interfaces
----------

<<<<<<< HEAD
The image exposes several TCP ports. The IMAP and POP ports used to access to the mailboxes. The LMTP port to ship messages to the mailboxes:
* 25: SMTP port
* 587: Submission port
* 465: SMTPS port
=======
The image exposes several TCP ports. The `IMAP` and `POP` ports used to access to the mailboxes. The `LMTP` port to ship messages to the mailboxes:

* 143: IMAP port
* 993: IMAPs port
* 110: POP port
* 995: POPs port
* 24: LMTP port
>>>>>>> dovecot-ldap/master

Data persistence
----------------

The image exposes three directories:
<<<<<<< HEAD
* /var/spool/postfix: Postfix mail queues. You should use a data volume in order to save the queue content if the container restarts.
* /etc/ssl/localcerts: Service certificate and keys are stored in this volume. Postfix is expecting the following PEM files: `/etc/ssl/localcerts/smtp.cert.pem` and `/etc/ssl/localcerts/smtp.key.pem`. If none are provided, the startup script will generate new keys and self-signed certificate.
* /etc/postfix: If you want to override the default configurations, you can use this volume to make Postfix use your files.
=======
* /var/mail: Actual mailboxes are stored in this volume. You should implement some backup strategies on those.
* /etc/ssl/localcerts: Service certificate and keys are stored in this volume. Dovecot is expecting the following PEM files: `/etc/ssl/localcerts/imap.cert.pem` and `/etc/ssl/localcerts/imap.key.pem`. If none are provided, the startup script will generate new keys and self-signed certificate.
* /etc/dovecot: If you want to override the default configurations, you can use this volume to make Dovecot use you files.
>>>>>>> dovecot-ldap/master

Usage
-----

The most simple use would be to start the application like so :

<<<<<<< HEAD
    docker run -d
    -p 25:25
    --link ldap-container:ldap
    --link mda-container:mda
    -e LDAP_USER_FIELD="uid"
    -e LDAP_BASE="ou=users,dc=yourdomain,dc=com"
    -e DOMAIN="yourdomain.com"
    -e HOSTNAME="smtp.yourdomain.com"
    teid/postfix-ldap

However, you should use your own certificate and a data-only container to persist the postfix queues:

    docker run -d
    -p 587:587
    -p 465:465
    --link ldap-container:ldap
    --link mda-container:mda
    --volumes-from smtp-certs
    --volumes-from smtp-queues
    -e LDAP_USER_FIELD="uid"
    -e LDAP_BASE="ou=users,dc=yourdomain,dc=com"
    -e DOMAIN="yourdomain.com"
    -e HOSTNAME="smtp.yourdomain.com"
    teid/postfix-ldap

The following environment variables allows you to override some LDAP configurations:
* LDAP_BASE: The base dn of the LDAP users
* LDAP_USER_FIELD: The name of the LDAP field used to check `username`
* DOMAIN: The domain used for local delivery (forward to the `mda` host)
* HOSTNAME: The name resolution of the container public IP (ex: `smtp.yourdomain.com`. Used during HELO commands. Some remote SMTP server might refuse your messages if this variable is missing or misconfigured

*Note: If you are using a custom configuration volume with this variables, your configuration files might be altered. You should not use both features.*
=======
    docker run -d 
    -p 143:143
    --link ldap-container:ldap
    -e LDAP_USER_FIELD="uid"
    -e LDAP_BASE="ou=users,dc=yourdomain,dc=com"
    teid/dovecot-ldap

However, you should use your own certificate and a data-only container to store the mailboxes

    docker run -d
    -p 993:993
    --link ldap-container:ldap
    --volumes-from imap-certs
    --volumes-from imap-data
    -e LDAP_USER_FIELD="uid"
    -e LDAP_BASE="ou=users,dc=yourdomain,dc=com"
    teid/dovecot-ldap

The following environment variables allows you to override some LDAP configurations:
* LDAP_BASE: The base dn of the LDAP users
* LDAP_USER_FIELD: The field name of your LDAP users used as `username` field

*Note: If you are using a custom configuration volume with this variables, your configuration files might be altered. You should not use both features.*

The user are authenticated thanks to the user part of the address (`user@domain`). So the `LDAP_USER_FIELD` should contains the usernames without the address extensions. The LDAP auth will use the bind method
>>>>>>> dovecot-ldap/master
