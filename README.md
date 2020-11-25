# Welcome to the Cowrie Docker GitHub repository

This is the official repository for the Cowrie SSH and Telnet
Honeypot Docker effort. It contains Dockerfiles that you can use
to build [Cowrie](https://github.com/micheloosterhof/cowrie) Docker
images.

## Quick Trial

To run Cowrie in Docker locally with creating your own image, run

```
docker run -p 2222:2222/tcp cowrie/cowrie
```

Then run an SSH client to port 2222 to test it:

```
ssh -p 2222 root@localhost
```

## What is Cowrie

Cowrie is a medium interaction SSH and Telnet honeypot designed to
log brute force attacks and the shell interaction performed by the
attacker.

# Building
Note that you will need to install Docker.

Run the following command to build all the images:

```
$ make all
```

# Configuring Cowrie in Docker

Cowrie in Docker can be configured using environment variables. The
variable should have the section name in capitals, followed by the
stanza in capitals. An example is below to enable telnet support

```
COWRIE_TELNET_ENABLED=yes
```

Alternatively, Cowrie in Docker can use an 'etc' volume to store
configuration data.  Create ```cowrie.cfg``` inside the etc volume
with the following contents to enable telnet in your Cowrie Honeypot
in Docker

```
[telnet]
enabled = yes
```
