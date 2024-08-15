/*
OSCdef.trace(true, true)
OSCdef.trace(false)
*/

// set the addresses to forward to:
// known addresses in local network,
// and thru port 8999 like a direct flatcat;
// should work to wake up
NetAddr.broadcastFlag = true;
NTMI.flatcat.fwdAddrs = List[
	NetAddr("192.168.4.195", 8999)
];

NTMI.flatcat.fwdFunc = OSCFunc({ |msg|
	NTMI.flatcat.fwdAddrs.do(_.sendMsg(*msg));
}, \flatcat).permanent_(true);


NTMI.flatcat.fwdFunc.disable;
