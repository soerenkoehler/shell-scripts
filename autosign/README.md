Autosign
========

Idea and Goal
-------------

Say, you have some application, which has some email capability but offers no support for encryption or signing. Under Windows there are solutions like [GPGrelay](https://www.heise.de/download/product/gpgrelay-57604). For Linux you have to use a real MTA (mail transfer agent) and configure it as an SMTP-proxy. Since it is linked on the GnuPG project site, the first idea may be to use [GNU Anubis](https://www.gnu.org/software/anubis/), but you have to compile it yourself and I didn't get it working with my ISP's remote MTA. So I tried [Postfix](http://www.postfix.org) - and although it seemed way more complex, in the end it is quite simple to set up.

Installation and Setup
----------------------

The installation described here was done on Fedora 23. The documentation might become inaccurate due to other environments or newer package versions - so feel free to consult other sources in the internet.

I've tried to name any placeholders in the code snippets with obvious generic names so you can replace them with your real data.

### 1. Install required software ###

Ask your friendly package manager (dnf, yum, apt, ...) to install the required packages:
```
dnf install gnupg2 postfix
```

### 2. Setup the local mail server ###

Modify `/etc/postfix/main.cf` and uncomment the following line. This restricts forwarding to mail received from the local machine.
```
mynetworks_style = host
```

### 3. Setup the remote mail server ###

Modify `/etc/postfix/main.cf` and edit/add the following lines. It will enable postfix to send mail to your remote MTA using SSL/TLS. If your remote MTA requires different settings, please consult the postfix documentation.
```
relayhost = examplehost:port
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/smtp-passwd
smtp_sasl_security_options = noanonymous
smtp_tls_wrappermode = yes
smtp_tls_security_level = encrypt
```

You need to create the password file `/etc/postfix/smtp-passwd` with one entry:
```
examplehost:port remoteusername:remotepassword
```

Attention:
- The separator between host and credentials is a __whitespace__.
- The separators between host and port as well as between username and password are __colons__.

For some reason, you have to convert the password file to a DB file. So run:
```
cd /etc/postfix
postmap smtp-passwd
```

see also: [Configuring SASL authentication in the Postfix SMTP/LMTP client](http://www.postfix.org/SASL_README.html#client_sasl)

### 4. Milestone: Test your new SMTP proxy ###

Now you can start postfix. The postfix package in Fedora came with systemd-support, so it's just:
```
systemctl enable postfix
systemctl start postfix
```
The first line ensures that the service starts on logon and the second line starts it immediately for our test. Configure your mail client to use `localhost:25` as the SMTP port and send some mail.

### 5. Create the filter ###

The simplest approach to process the body of a mail in postfix seems to be the [after-queue-filter](http://www.postfix.org/FILTER_README.html). Basically you can follow the [Simple content filter example](http://www.postfix.org/FILTER_README.html#simple_filter).

Pitfalls and differences to the boilerplate code:
- Postfix may leave the `sendmail` command untouched and use `sendmail.postfix` instead. As this was the case with Fedora 23, I had to use the latter in `autosign-filter`.
- The shell variable `$$` contains the process ID of the filter script and is used to separate the temporary files of different invocations. For debugging and testing I found it more intuitive to have `$$` as filename instead of extension. 
- Using a seperate output file and checking for its existence allows debugging without really sending the mail. Just write to e.g. `$$.tmp` instead of `$$.out`.

The files:  
[`autosign-filter`](./autosign-filter)  
[`autosign_action`](./autosign-action)

=> http://www.postfix.org/FILTER_README.html#simple_filter

### 6. Milestone: Create autosigned mail ###

Security Concerns
-----------------
