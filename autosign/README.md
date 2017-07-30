Autosign
========

Idea and Goal
-------------

Say, you have some application, which has some email capability but offers no support for encryption or signing. Under Windows there are solutions like [GPGrelay](https://www.heise.de/download/product/gpgrelay-57604). For Linux you have to use a real MTA (mail transfer agent) and configure it as an SMTP-proxy. Since it is linked on the GnuPG project site, the first idea may be to use [GNU Anubis](https://www.gnu.org/software/anubis/), but you have to compile it yourself and I didn't get it working with my ISP's remote MTA. So I tried [Postfix](http://www.postfix.org), and although it seemed way more complex, in the end it is quite simple to set up.

Installation and Setup
----------------------

### 1. Install required software ###

Ask your friendly package manager (dnf, yum, apt, ...) to install the required packages:
```
dnf install gnupg2 postfix
```

### 2. Setup the remote mail server ###

Modify `/etc/postfix/main.cf` and add the following lines. It will enable postfix to send mail to your remote MTA using SSL/TLS. If your remote MTA requires different settings, please consult the postfix documentation.
```
relayhost = smtp.example.org:465
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/smtp-passwd
smtp_sasl_security_options = noanonymous
smtp_tls_wrappermode = yes
smtp_tls_security_level = encrypt
```
Now you can test your new SMTP proxy. Configure your mail client to use `localhost:25` as the SMTP port and send some mail.

Security Concerns
-----------------
