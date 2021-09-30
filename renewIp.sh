#!/bin/bash
#
# Connect to TOR unix socket and send a signal for new identity (IP)

cmd="AUTHENTICATE\r\nsignal NEWNYM" && ( echo -e "$cmd" && sleep 1 ) | socat - UNIX-CONNECT:/var/run/tor/control

