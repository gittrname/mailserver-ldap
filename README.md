mailserver-ldap
====

Postfix + Dovecot によるメールサーバーです メールユーザーはLDAPで管理します。  
teid氏作成の「teid/postfix-ldap」と「teid/dovecot-ldap」を  
ひとまとめにしつつ587の各ポートで認証を必須するなどの変更を加えています。  

*■使用ポート*  
・25  SMTP  
・587 Submission  
・465 SMTPs  
・143 IMAP  
・993 IMAPs  
・110 POP  
・995 POPs  
・4190 managesieve  
  
*■データディレクトリ*  
・/var/mail  
	アカウントメールボックス保存先  
・/etc/ssl/localcerts/  
	SSL証明書格納先  

*■環境変数*
・LDAP_BASE  
　このDNを起点にLDAPの探索を行います。  
・LDAP_USER_FIELD  
　ここに指定したfieldでユーザー認証を行います。  
・DOMAIN  
　ここに記載されたドメイン当てのメールをDovecotにフォーワードします。  
・HOSTNAME  
　メールサーバーのホスト名。  
・UPSTREAM_PROXY  
　ELBなどのリバースプロキシ元のIPアドレスを記載します。
　proxy_protocolに対応した設定が有効になります。

## 使用例
*・ビルド*
```bash
    $ git clone https://github.com/gittrname/mailserver-ldap.git  
    $ docker build -t mailserver-ldap mailserver-ldap  
```
*・起動*
```bash
// LDAP
$ docker run -d \
	--name ldap \
	-p 80:80 \
	-e LDAP_DOMAIN=example.com \
	-e LDAP_ADMIN_PWD=password \
	-e LDAP_ORGANISATION="LDAP for docker." \
	sharaku/ldap

// Postfix + Dovecot
$ docker run -d \
	--name mail \
	--link ldap \
	-p 25:25 \
	-p 587:587 \
	-p 465:465 \
	-p 143:143 \
	-p 993:993 \
	-p 110:110 \
	-p 995:995 \
	-e LDAP_SERVER="ldap" \
	-e LDAP_BASE=ou="ou=People,dc=example,dc=com" \
	-e LDAP_USER_FIELD=uid \
	-e DOMAIN="example.com" \
	-e HOSTNAME="mail.example.com" \
	mailserver-ldap
```
*・docker-compose.yml例*
```bash
version: '2'  
services:  
  mail:  
    build: mailserver-ldap  
    ports:  
      - "25:25"  
      - "465:465"  
      - "587:587"  
      - "110:110"  
      - "143:143"  
      - "995:995"  
      - "993:993"  
    links:  
      - ldap  
    extra_hosts:  
      - "mail.example.com:127.0.0.1"  
    environment:  
      - "LDAP_SERVER=ldap"  
      - "DOMAIN=example.com"  
      - "HOSTNAME=mail.example.com"  
      - "LDAP_BASE=ou=People,dc=example,dc=com"  
      - "LDAP_USER_FIELD=uid"  
  ldap:  
    image: sharaku/ldap  
    ports:  
      - "80:80"  
    environment:  
      - "LDAP_DOMAIN=example.com"  
      - "LDAP_ADMIN_PWD=password"  
      - "LDAP_ORGANISATION=LDAP for docker."  
```
