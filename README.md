# Welcome to the Cowrie Docker GitHub repository

This is the official repository for the Cowrie SSH and Telnet
Honeypot Docker effort. It contains Dockerfiles that you can use
to build [Cowrie](https://github.com/micheloosterhof/cowrie) Docker
images.

## What is Cowrie

Cowrie is a medium interaction SSH and Telnet honeypot designed to
log brute force attacks and the shell interaction performed by the
attacker.

## The Splunk Base Image: base-debian-9
In order to minimize image size and provide a stable foundation for
other images to build on, we elected to use `debian:stretch-slim`
for our base image. `debian:stretch-slim` gives us the latest version
of the Linux Debian operating system in a tiny 55 megabytes. 

# Configuring Cowrie in Docker

Cowrie in Docker is set up to use an 'etc' volume to store configuration
data.  Create ```cowrie.cfg``` inside the etc volume with the
following contents to enable Telnet in your Cowrie Honeypot in
Docker

```
[telnet]
enabled = yes
```
