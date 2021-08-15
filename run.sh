#!/bin/sh

# Backup your old config
OLD_QDISC=$(cat /proc/sys/net/core/default_qdisc)
OLD_TCP_CONTROL=$(cat /proc/sys/net/ipv4/tcp_congestion_control)

_rollback(){
    echo $OLD_QDISC > /proc/sys/net/core/default_qdisc
    echo $OLD_TCP_CONTROL > /proc/sys/net/ipv4/tcp_congestion_control
}

rollback(){
    _rollback
    if [ -z "$1" ];then
        echo "Failed: Current kernel did not support this feature"
    fi;
    exit 1
}


echo 'bbr' > /proc/sys/net/ipv4/tcp_congestion_control
if [ $? -ne 0 ];then
    rollback
fi;
echo "Great, kernel support bbr feature, downloading systemd service to your system..."
_rollback
wget -O /etc/systemd/system/kernel-bbr.service https://raw.githubusercontent.com/wikihost-opensource/enable-bbr/main/kernel-bbr.service
systemctl start kernel-bbr > /dev/null
if [ "`systemctl is-active kernel-bbr.service`" == "active" ];then
    systemctl enable kernel-bbr > /dev/null
    echo "Success, bbr kernel feature is enabled"
    exit 0
fi;

rollback
