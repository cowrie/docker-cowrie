# Welcome to the Cowrie Docker GitHub repository

This is the official repository for the Cowrie SSH and Telnet
Honeypot Docker effort. It contains Dockerfiles that you can use
to build [Cowrie](https://github.com/micheloosterhof/cowrie) Docker
images.

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

Cowrie in Docker is set up to use an 'etc' volume to store configuration
data.  Create ```cowrie.cfg``` inside the etc volume with the
following contents to enable Telnet in your Cowrie Honeypot in
Docker

```
[telnet]
enabled = yes
```

