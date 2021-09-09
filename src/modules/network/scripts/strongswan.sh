#! /bin/bash -e

apt-get update
apt-get install -y strongswan

cat <<EOF > /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1 
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF

cat <<EOF > /etc/ipsec.conf
config setup
        charondebug="all"
        uniqueids=yes
conn bridge
        type=tunnel
        auto=start
        keyexchange=ikev2
        left=${HOST_PRIVATE_IP}
        leftid=${HOST_PUBLIC_IP}
        leftsubnet=${HOST_SUBNET}
        leftauth=psk
        right=${REMOTE_PUBLIC_IP}
        rightsubnet=${REMOTE_SUBNET}
        rightauth=psk
        ike=aes256-sha256-modp2048!
        esp=aes256-sha256-modp2048!
        aggressive=no
        keyingtries=30
        ikelifetime=28800s
        lifetime=3600s
        dpddelay=30s
        dpdtimeout=120s
        dpdaction=restart
EOF

cat <<EOF > /etc/ipsec.secrets
${HOST_PUBLIC_IP} ${REMOTE_PUBLIC_IP} : PSK "${STRONGSWAN_PASSWORD}"
EOF

iptables -t nat -A POSTROUTING -s ${REMOTE_SUBNET} -d ${HOST_SUBNET} -j MASQUERADE

sysctl -p /etc/sysctl.conf

ipsec rereadsecrets

ipsec reload