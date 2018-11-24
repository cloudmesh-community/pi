# Raspberry Pi setup

Raspberry Pi setup scripts to complement the manual

## Setting up the Raspberry Pi

The Raspberry Pi runs a Linux operating system based on the Debian distribution
that is called Raspbian. Some users may not be too familiar with administering a
Linux system so we have developed various scripts that can help you setup and
work with your Raspberry Pi system.

To use these scripts there are a few manual steps that must be taken. First, if
you have installed the Raspbian Stretch Lite distribution (which we recommend)
then your Pi will have very few development tools and utilities installed. In
order to run many of these scripts you will need to first install some tools.
The first tool you will need is `git`. `git` is a tool to access data on a
version control system and it can be used to download the latest version of
these scripts. After booting your Raspberry Pi and connecting to it either with
a keyboard and monitor or over ssh, you will need to update the packages and
install git. Please run the following commands (NOTE: your Pi will need to be
connected to the internet for these commands to work properly):

```bash
$ sudo apt-get update
$ sudo apt-get install -y git
```

When this is complete you can then checkout (get a copy of) the latest version
of these tools on your Raspberry Pi with the command:

```bash
$ git clone https://github.com/cloudmesh-community/pi.git
```

This will create a directory called `pi` in the current folder. We recommend
adding the `bin` directory to your path for convenience in using the scripts
found there. This can be accomplished by running the following lines:

```bash
$ cat << 'EOF' >> $HOME/.profile

if [ -d "$HOME/pi/bin" ] ; then
    PATH="$HOME/pi/bin:$PATH"
fi
EOF
```

```bash
$ echo 'if [ -d "$HOME/pi/bin" ] ; then' >> ~/.profile
$ echo '    PATH="$HOME/pi/bin:$PATH"' >> ~/.profile
$ echo 'fi' >> ~/.profile
```

This will affect any future login shells. The changes can be made in the current
shell by sourcing `.profile`:

```bash
$ source ~/.profile
```
