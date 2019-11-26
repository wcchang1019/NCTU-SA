#!/bin/sh
mkdir /home/wcchang/ftp
cp -a /ftp/. /home/wcchang/ftp
rm -rf /ftp
rm -rf /home/ftp
zpool create mypool mirror /dev/da1 /dev/da2
zfs set mountpoint=/ftp mypool
zfs set atime=off mypool
zfs set compression=lz4 mypool
zfs create mypool/public
zfs set atime=off mypool/public
zfs set compression=lz4 mypool/public
zfs create mypool/hidden
zfs set atime=off mypool/hidden
zfs set compression=lz4 mypool/hidden
zfs create mypool/upload
zfs set atime=off mypool/upload
zfs set compression=lz4 mypool/upload
cp -a /home/wcchang/ftp/. /ftp
rm -rf /home/wcchang/ftp
ln -s /ftp /home/ftp
chmod 1777 /ftp/upload
chown sysadm:sysadm /ftp/upload
chmod 777 /ftp/public
chown sysadm:sysadm /ftp/public
chmod 771 /ftp/hidden
chown sysadm:hw3groups /ftp/hidden
mkdir /ftp/hidden/treasure
touch /ftp/hidden/treasure/secret
