Postfix + Dovecot �ɂ�郁�[���T�[�o�[�� ���[�����[�U�[��LDAP�ŊǗ����܂��B

teid���쐬�́uteid/postfix-ldap�v�Ɓuteid/dovecot-ldap�v��
�ЂƂ܂Ƃ߂ɂ���25�A587�̊e�|�[�g�ŔF�؂�K�{����Ȃǂ̕ύX�������Ă��܂��B

���g�p�|�[�g
�E25  SMTP
�E587 Submission
�E465 SMTPs
�E143 IMAP
�E993 IMAPs
�E110 POP
�E995 POPs

���f�[�^�f�B���N�g��
�E/var/mail
�@�A�J�E���g���[���{�b�N�X�ۑ���
�E/etc/ssl/localcerts/
�@SSL�ؖ����i�[��

�����ϐ�
�ELDAP_BASE
�@����DN���N�_��LDAP�̒T�����s���܂��B
�ELDAP_USER_FIELD
�@�����Ɏw�肵��field�Ń��[�U�[�F�؂��s���܂�
�EDOMAIN
�@�����ɋL�ڂ��ꂽ�h���C�����Ẵ��[����Dovecot�Ƀt�H�[���[�h���܂��B
�EHOSTNAME
�@���[���T�[�o�[�̃z�X�g��

���g�p��
�E�r���h
# git clone [github]
# docker build -t mailserver-ldap mailserver-ldap

�E�N��
// LDAP
# docker run -d \
	--name ldap \
	-p 80:80 \
	-e LDAP_DOMAIN=example.com \
	-e LDAP_ADMIN_PWD=password \
	-e LDAP_ORGANISATION="LDAP for docker." \
	sharaku/ldap

// Postfix + Dovecot
# docker run -d \
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


�T���v���jdocker-compose.yml��
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
