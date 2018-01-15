#!/bin/bash
set -e

# Initialize localmacros as an empty file
echo -n "" > /etc/exim4/exim4.conf.localmacros

if [ "$MAILNAME" ]; then
	echo "MAIN_HARDCODE_PRIMARY_HOSTNAME = $MAILNAME" > /etc/exim4/exim4.conf.localmacros
	echo $MAILNAME > /etc/mailname
fi

if [ "$KEY_PATH" -a "$CERTIFICATE_PATH" ]; then
	if [ "$MAILNAME" ]; then
	  echo "MAIN_TLS_ENABLE = yes" >>  /etc/exim4/exim4.conf.localmacros
	else
	  echo "MAIN_TLS_ENABLE = yes" >>  /etc/exim4/exim4.conf.localmacros
	fi
	cp $KEY_PATH /etc/exim4/exim.key
	cp $CERTIFICATE_PATH /etc/exim4/exim.crt
	chgrp Debian-exim /etc/exim4/exim.key
	chgrp Debian-exim /etc/exim4/exim.crt
	chmod 640 /etc/exim4/exim.key
	chmod 640 /etc/exim4/exim.crt
fi

opts=(
	dc_local_interfaces "[0.0.0.0]:${PORT:-25} ; [::0]:${PORT:-25}"
	dc_relay_nets "$(ip addr show dev eth0 | awk '$1 == "inet" { print $2 }' | xargs | sed 's/ /:/g')${RELAY_NETWORKS}"
)

if [ "$DISABLE_IPV6" ]; then 
        echo 'disable_ipv6=true' >> /etc/exim4/exim4.conf.localmacros
fi

if [ "$DOMAINS" ]; then
	opts+=(
		dc_other_hostnames "${DOMAINS}"
		dc_eximconfig_configtype 'internet'
	)
else
	opts+=(
		dc_eximconfig_configtype 'internet'
	)
fi

echo "SYSTEM_ALIASES_PIPE_TRANSPORT = address_pipe" >> /etc/exim4/exim4.conf.localmacros

# Create our watchperson user account
USER_ID=${UID:-9001}
echo "Creating watchperson with UID $USER_ID..."
useradd --home /mail --system --uid $USER_ID watchperson

# Set up ripmail alias for our watchperson user 
echo "watchperson: |/bin/ripmail.sh" >> /etc/aliases

/bin/set-exim4-update-conf "${opts[@]}"

exec "$@"
