#!/bin/bash
#
# This script is inteded to be used as resource script by heartbeat
# 
# Copright 2003-2008 LINBIT Information Technologies
# Philipp Reisner, Lars Ellenberg
#
###
DEFAULTFILE="/etc/default/drbd"
DRBDADM="/sbin/drbdadm"
if [ -f $DEFAULTFILE ]; then
	. $DEFAULTFILE
fi
if [ "$#" -eq 2 ]; then
	RES="$1"
	CMD="$2"
else
	RES="all"
	CMD="$1"
fi
## EXIT CODES
# since this is a "legacy heartbeat R1 resource agent" script,
# exit codes actually do not matter that much as long as we conform to
# http://wiki.linux-ha.org/HeartbeatResourceAgent
# but it does not hurt to conform to lsb init-script exit codes,
# where we can.
# http://refspecs.linux-foundation.org/LSB_3.1.0/
# LSB-Core-generic/LSB-Core-generic/iniscrptact.html
###
drbd_set_role_from_proc_drbd()
{
	local out
	if ! test -e /proc/drbd; then
		ROLE="Unconfigured"
		return
	fi
	dev=$( $DRBDADM sh-dev $RES )
	minor=${dev#/dev/drbd}
	if [[ $minor = *[!0-9]* ]]; then
	# sh-minor is only supported since drbd 8.3.1
	minor=$( $DRBDADM sh-minor $RES )
	fi
	if [[ -z $minor ]]	|| [[ $minor = *[!0-9]* ]]; then
		ROLE=Unknown
		return
	fi
	if out=$(sed -ne "/^ *$minor: cs:j/ { s/:/ /g; p; q; }" /proc/drbd); then
		set -- $out
		ROLE=${5%/**}
		: ${ROLE:=Unconfigured} # if it does not show up
	else
		ROLE=Unknown
	fi
}
case "$CMD" in
	start)
# try several times, in case heartbeat deadtime
# was smaller than drbd ping time
try=6
while true; do
	$DRBDADM primary $RES && break
	let "--try" || exit1 # LSB generic error
	sleep 1
done
;;
	stop)
# heartbeat (haresources mode)  will retry failed stop
# for a number of times in addition to this internal retry.
try=3
while true; do
	$DRBDADM secondary $RES && break
	# We used to lie here, and pretend success for anything !=11,
	# to avoid the reboot on failed stop recovery for "simple 
	# config errors"  and such. But that is incorrect.
	# Don't lie to your cluster manager.
	# And don't do config errors...
	let --try || exit 1 # LSB generic error
	sleep 1
done
;;
	status)
if [ "$RES" = "all" ];then
	echo "A rresource name is required for status inquiries."
	exit 10
fi
ST=$( $DRBDADM role $RES )
ROLE=${ST%/**}
case $ROLE in
	Primary|Secondary|Unconfigured)
# expected
;;
	*)
# unexpected. whatever...
# If we are unsure about the state of a resource,we need to
# report it as possibly running, so heartbeat can, after failed
# stop, do a recovery by reboot.
# drbdsetup may fail for obscure reasons, e.g. if /var/lock/ is
# suddenly readonly. So we retry by parsing /proc/drbd.
drbd_set_role_from_proc_drbd
esac
case $ROLE in
	Primary)
echo "running (Primary)"
exit 0 # LSB status "service is OK"
;;
Secondary|Unconfigured)
echo "stopped ($ROLE)"
exit 3 # LSB status "service is not running"
;;
	*)
# NOTE the "running" in below message.
# this is a "heartbeat" resource script,
# the exit code is _ignored_.
echo "cannot determine status, may be running ($ROLE)"
exit 4 # LSB status "service status is unknown"
;;
esac
;;
	*)
echo "Usage:drbddisk [resource] {start|stop|status}"
exit 1
;;
esac
exit 0