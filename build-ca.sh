#!/bin/bash

AUTHOR="Maple"
VPN="Cisco SG for Maple"
DOMAIN="miao.hu"
CLIENT="user"

cd /usr/local/etc/ocserv
mkdir ca
cd ca

cat << EOF > ca.tmpl
cn = "$VPN"
organization = "$AUTHOR"
serial = 1
expiration_days = 1000
ca
signing_key
cert_signing_key
crl_signing_key
EOF

cat << EOF > server.tmpl
cn = "$DOMAIN"
organization = "$AUTHOR"
serial = 2
expiration_days = 1000
signing_key
encryption_key
tls_www_server
EOF

certtool --generate-privkey --outfile ca-key.pem
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem
certtool --generate-privkey --outfile server-key.pem
certtool --generate-certificate --load-privkey server-key.pem \
--load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem \
--template server.tmpl --outfile server-cert.pem

cat << EOF > user.tmpl
cn = "$CLIENT"
serial = 1824
expiration_days = 1000
signing_key
tls_www_client
EOF

certtool --generate-privkey --outfile user-key.pem
certtool --generate-certificate --load-privkey user-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template user.tmpl --outfile user-cert.pem
openssl pkcs12 -export -clcerts -in user-cert.pem -inkey user-key.pem -out user.p12

cat << EOF > /usr/local/etc/ocserv/ocserv.conf
#证书登录
auth = "certificate"
max-clients = 1024
max-same-clients = 16
tcp-port = 10443
udp-port = 10443
keepalive = 32400
dpd = 90
mobile-dpd = 1800
try-mtu-discovery = true
server-cert = /usr/local/etc/ocserv/ca/server-cert.pem
server-key = /usr/local/etc/ocserv/ca/server-key.pem
ca-cert = /usr/local/etc/ocserv/ca/ca-cert.pem
cert-user-oid = 2.5.4.3

tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-VERS-SSL3.0"
auth-timeout = 40
min-reauth-time = 120
cookie-timeout = 300
deny-roaming = false
rekey-time = 172800
rekey-method = ssl
use-utmp = true
use-occtl = true
pid-file = /var/run/ocserv.pid
socket-file = /var/run/ocserv-socket
run-as-user = nobody
run-as-group = daemon
device = vpns
output-buffer = 23000
# default-domain = example.com
ipv4-network = 10.0.1.0
ipv4-netmask = 255.255.255.0
dns = 8.8.8.8
dns = 8.8.4.4
ping-leases = false
cisco-client-compat = true

no-route = 0.0.0.0/254.0.0.0
no-route = 14.0.0.0/255.0.0.0
no-route = 27.0.0.0/255.0.0.0
no-route = 36.0.0.0/255.0.0.0
no-route = 39.0.0.0/255.0.0.0
no-route = 42.0.0.0/254.0.0.0
no-route = 45.64.0.0/255.192.0.0
no-route = 47.80.0.0/255.240.0.0
no-route = 47.96.0.0/255.224.0.0
no-route = 49.0.0.0/255.0.0.0
no-route = 54.222.0.0/255.254.0.0
no-route = 58.0.0.0/254.0.0.0
no-route = 60.0.0.0/254.0.0.0
no-route = 91.232.0.0/255.248.0.0
no-route = 101.0.0.0/255.0.0.0
no-route = 102.0.0.0/254.0.0.0
no-route = 106.0.0.0/255.0.0.0
no-route = 110.0.0.0/254.0.0.0
no-route = 112.0.0.0/240.0.0.0
no-route = 139.0.0.0/255.240.0.0
no-route = 139.128.0.0/255.254.0.0
no-route = 139.148.0.0/255.254.0.0
no-route = 139.152.0.0/255.248.0.0
no-route = 139.170.0.0/255.255.0.0
no-route = 139.176.0.0/255.255.0.0
no-route = 139.183.0.0/255.255.0.0
no-route = 139.186.0.0/255.255.0.0
no-route = 139.188.0.0/255.252.0.0
no-route = 139.192.0.0/255.224.0.0
no-route = 139.224.0.0/255.255.0.0
no-route = 139.226.0.0/255.254.0.0
no-route = 140.75.0.0/255.255.0.0
no-route = 140.143.0.0/255.255.0.0
no-route = 140.205.0.0/255.255.0.0
no-route = 140.206.0.0/255.254.0.0
no-route = 140.210.0.0/255.255.0.0
no-route = 140.224.0.0/255.255.0.0
no-route = 140.237.0.0/255.255.0.0
no-route = 140.240.0.0/255.255.0.0
no-route = 140.243.0.0/255.255.0.0
no-route = 140.246.0.0/255.255.0.0
no-route = 140.249.0.0/255.255.0.0
no-route = 140.250.0.0/255.255.0.0
no-route = 140.255.0.0/255.255.0.0
no-route = 144.0.0.0/255.254.0.0
no-route = 144.6.0.0/255.254.0.0
no-route = 144.12.0.0/255.255.0.0
no-route = 144.52.0.0/255.252.0.0
no-route = 144.122.0.0/255.254.0.0
no-route = 144.255.0.0/255.255.0.0
no-route = 150.0.0.0/255.192.0.0
no-route = 150.115.0.0/255.255.0.0
no-route = 150.121.0.0/255.255.0.0
no-route = 150.122.0.0/255.255.0.0
no-route = 150.128.0.0/255.254.0.0
no-route = 150.138.0.0/255.254.0.0
no-route = 150.223.0.0/255.255.0.0
no-route = 150.242.0.0/255.255.0.0
no-route = 150.254.0.0/255.254.0.0
no-route = 152.104.0.0/255.248.0.0
no-route = 153.0.0.0/255.254.0.0
no-route = 153.3.0.0/255.255.0.0
no-route = 153.34.0.0/255.254.0.0
no-route = 153.36.0.0/255.254.0.0
no-route = 153.96.0.0/255.252.0.0
no-route = 153.100.0.0/255.254.0.0
no-route = 153.118.0.0/255.254.0.0
no-route = 157.0.0.0/255.240.0.0
no-route = 157.16.0.0/255.252.0.0
no-route = 157.61.0.0/255.255.0.0
no-route = 157.122.0.0/255.255.0.0
no-route = 157.148.0.0/255.255.0.0
no-route = 157.156.0.0/255.252.0.0
no-route = 157.255.0.0/255.255.0.0
no-route = 159.226.0.0/255.255.0.0
no-route = 161.207.0.0/255.255.0.0
no-route = 162.105.0.0/255.255.0.0
no-route = 163.0.0.0/255.254.0.0
no-route = 163.44.0.0/255.252.0.0
no-route = 163.48.0.0/255.240.0.0
no-route = 163.125.0.0/255.255.0.0
no-route = 163.136.0.0/255.248.0.0
no-route = 163.177.0.0/255.255.0.0
no-route = 163.178.0.0/255.254.0.0
no-route = 163.204.0.0/255.255.0.0
no-route = 166.110.0.0/255.254.0.0
no-route = 167.139.0.0/255.255.0.0
no-route = 167.189.0.0/255.255.0.0
no-route = 168.160.0.0/255.255.0.0
no-route = 171.0.0.0/255.128.0.0
no-route = 171.208.0.0/255.240.0.0
no-route = 175.0.0.0/255.0.0.0
no-route = 180.0.0.0/252.0.0.0
no-route = 202.0.0.0/254.0.0.0
no-route = 210.0.0.0/254.0.0.0
no-route = 218.0.0.0/254.0.0.0
no-route = 220.0.0.0/252.0.0.0
#网易云音乐
no-route = 123.150.52.196/255.255.255.0
no-route = 123.150.53.156/255.255.255.0
no-route = 60.165.45.14/255.255.255.0
no-route = 115.102.0.50/255.255.255.0
no-route = 123.58.180.105/255.255.255.0
no-route = 222.170.95.35/255.255.255.0
EOF