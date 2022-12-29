# TDD relay-server

Relay server for the [TDD Project](https://github.com/glevand/tdd-project).

Once a remote machine has booted it needs to let the master know it is and ready 
to receive commands, and if the remote machine was configured via DHCP it must 
provide its IP address to the master.  The tdd-relay server is at a known 
network location and acts as a message relay server from the remote machine to 
the master.  If there is a firewall between the master and any remote machines 
the relay service must accessible from outside the firewall.

For setup see the TDD relay service
[README](https://github.com/glevand/tdd--docker/blob/master/tdd-relay/README.md).

## Licence & Usage

All files in the [TDD Project](https://github.com/glevand/tdd-project), unless
otherwise noted, are covered by an
[MIT Plus License](https://github.com/glevand/tdd--script-lib/blob/master/mit-plus-license.txt).
The text of the license describes what usage is allowed.
