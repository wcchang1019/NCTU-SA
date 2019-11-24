#!/bin/sh
chmod 1777 /home/ftp/upload
chown sysadm:sysadm /home/ftp/upload
chmod 777 /home/ftp/public
chown sysadm:sysadm /home/ftp/public
chmod 771 /home/ftp/hidden
chown sysadm:hw3groups /home/ftp/hidden
mkdir /home/ftp/hidden/treasure
touch /home/ftp/hidden/treasure/secret
