#!/bin/bash

#Stroyline: Script to create a wireguard server

# Create a private key
p="$(wg genkey)"

# create a public key
pub="$(echo ${p} | wg pubkey)"

# Set the addresses
address="10.10.10.1/24,192.168.1.1/24"



# Set the Listen prot
lport="51820"

# Create the format for the client configuration options
peerinfo="# ${address} 12.34.56.78:51820 ${pub} 10.10.10.1,8.8.8.8 1280 120 0.0.0.0/0"


echo "${peerinfo}
[Interface]
Address = ${address}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
Listenport = ${lport}
PrivateKey = ${p}
" > wg0.conf





: '

#server config

# [Interface]
# Address = 10.10.10.1/24,192.168.1.1/24
 #PostUp = /etc/wireguard/wg-up.bash
 #PostDown = /etc/wireguard/wg-down.bash
# ListenPort = 51820
# PrivateKey = KO0XW+9lPdirjNsSQlrzEuz1ReeisTznKHvfuRJ9hHw=


#client config


[Interface]
Address = 10.10.10.2/24
DNS = 10.10.10.1
PrivateKey = 2OI6heIlbb0MJuqI78f29Nq8hUuZDZU68Y6a/d1nu1M=


[Peer]
PublicKey = sONK9+pPEtIMlCkHaob2OIvvSpTCyZ+qOUdbYSdtiyM=

AllowedIPs = 0.0.0.0/0
Endpoint = 12.34.56.78:51820
PersistentKeepalive = 25

'
