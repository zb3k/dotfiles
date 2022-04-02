#!/bin/bash

# All "custom" vpns, are prefixed with "vpn-" as the tunnel name
VPN_NAME=$(nmcli -t -f NAME,TYPE,STATE con | awk -F: '$2=="vpn" {print $3}')

if [[ "${VPN_NAME}" =~ "activated" ]];
then
  echo "%{F#be5046}""%{F-} VPN"
else
  echo "%{F#617b94}""%{F-} VPN"
fi