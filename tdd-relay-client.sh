#!/bin/sh

my_addr() {
	ip route get 8.8.8.8 | egrep -o 'src [0-9.]*' | cut -f 2 -d ' '
}

set -x

echo ''
echo 'TDD Relay Client: start'

one_shot=${1}
pid=${$}
timeout=@@timeout@@
debug=1

if [ ${timeout} -ge 1 ]; then
	:
else
	timeout=301 # 5 minutes.
fi

if [ ${debug} ]; then
	echo '--- debug -------'
#	echo "${pid}" > /run/tdd-relay-client-${pid}.pid
#	date
#	uname -a
#	cat /etc/os-release
#	systemctl status networking.service
#	systemctl status ssh.service
	ip a
	netstat -atpn | grep ':22'
	cat /proc/cmdline
	cat /proc/sys/kernel/random/entropy_avail
	echo '-----------------'
	echo ''
fi

sleep 2s

triple="$(cat /proc/cmdline | egrep -o 'tdd_relay_triple=[^ ]*' | cut -d '=' -f 2)"

if [ ! ${triple} ]; then
	echo "TDD Relay Client: ERROR: Triple not found: '$(cat /proc/cmdline)'." >&2
	exit 2
fi

count=0
while [ ${count} -lt 10 ]; do
	ip_test="$(my_addr)"

	if [ ${ip_test} ]; then
		break
	fi

	echo "TDD Relay Client: WARNING: No IP address found." >&2
	dhclient -v
	ip a
	sleep 2s
done

server="$(echo ${triple} | cut -d ':' -f 1)"
port="$(echo ${triple} | cut -d ':' -f 2)"
token="$(echo ${triple} | cut -d ':' -f 3)"

count=0
while [ ${count} -lt ${timeout} ]; do
	msg="PUT:${token}:$(my_addr)"
	reply=$(echo -n ${msg} | nc -w10 ${server} ${port})
	if [ "${reply}" = 'QED' -o "${reply}" = 'UPD' -o "${reply}" = 'FWD' ]; then
		break
	fi
	count=$((count+5))
	sleep 5s
done

#if [ ${debug} ]; then
#	echo '--- debug -------'
#	systemctl status networking.service
#	systemctl status ssh.service
#	echo '-----------------'
#	echo ''
#fi

echo 'TDD Relay Client: end'

if [ ! ${one_shot} ]; then
	while :; do
		sleep 365d
	done
fi
