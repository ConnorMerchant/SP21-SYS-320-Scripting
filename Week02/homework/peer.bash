#!/bin/bash

# Storyline : Create peer Wireguard Conf file


# Name of the Peer User

echo -n "What is the User name? "
read User_Name

# Filename variable

UFile="${User_Name}-wgo.conf"

echo "${UFile}"

# Check if there a conf exists

if [[ -f "${UFile}" ]]
then

	#Promp to see if file is there and needs to be overwritten
	echo "The file ${UFile} exists."
	echo -n "Do you want to overwrite it? [y/N]"
	read to_overwrite

	if [[ "${to_overwrite}" == "N" || "{to_overwrite}" == "" ]]
	then

		echo "Exit..."
		exit 0

	elif [[ "${to_overwrite}" == "y" ]]
	then
		echo "Creating new Wireguard conf file named ${UFile}."

	#If the admin doenst specify yor N then error.
	else
	
		echo "Inavalid value"
		exit 1

	fi
	
fi
# Gen Private Key for user 
PrivKey="$(wg genkey)"
 
# Gen Pub  Key for user

UserPubKey="$(echo ${PrivKey} | wg pubkey)"

# Gen Preshared Key

PreKey="$(wg genpsk)"

#Client  Conf file sample
# 10.10.10.1/24,192.168.1.1/24 12.34.56.78:51820 uE3vEBoHNFb5ES+YJWxq8DaXwMr5Zvg284C1vx1670w= 10.10.10.1,8.8.8.8 1280 120 0.0.0.0/0


# Endpoint

Endpoint="$(head -1 wg0.conf |awk ' { print $3 } ')"
# Server Pub Key

ServerPubKey="$(head -1 wg0.conf |awk ' { print $4 } ')"


# DNS server

DNS="$(head -1 wg0.conf |awk ' { print $5 } ')"

#MTU

MTU="$(head -1 wg0.conf |awk ' { print $6 } ')"

#KeepAlive

KeepAlive="$(head -1 wg0.conf |awk ' { print $7 } ')"

#ListenPort

ListenPort="$(shuf -n1 -i 40000-50000)"

# Default routes for VPN
routes="$(head -1 wg0.conf |awk ' { print $8 } ')"

# Create the client conf for WG

echo "[Interface]
Address = 10.254.123.100/24
DNS = ${DNS}
ListenPort = ${ListenPort}
MTU = ${MTU}
PrivateKey = ${PrivKey}

[Peer]
AllowedIPS = ${routes}
PersistentKeepalive = ${KeepAlive}
PresharedKey = ${PreKey}
PublicKey = ${ServerPubKey}
Endpoint = ${Endpoint}


" > ${UFile}

# Add Peer conf to Server conf file

echo "# Connor begin

[Peer]
PublicKey = ${UserPubKey}
PresharedKey = ${PreKey}
AllowedIPS = 10.254.132.100/32
# Connor end
 " | tee -a wg0.conf
