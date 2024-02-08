/*
OscRouter for internet influences:

NTMIs send to an OSCRouter server,
which relays messages to other running NTMIs.
The first use of these is the changeVectors
created by local interfaces in setRel mode,
which go to influence all running processes
as the source 'xflux'.

NTMI.oscar.close;
NTMI.oscar.join;

*/

NTMI.localAddr = NetAddr.localAddr;

NTMI.myname = NTMI.myname ? unixCmdGetStdOut("hostname").reject(_ == Char.nl).asSymbol;
NTMI.mypwd = NTMI.mypwd ? "senha";

// use gencomp oscserver as default
NTMI.udkOscServerName = "gencomp.medienhaus.udk-berlin.de";
NTMI.oscServerName = NTMI.oscServerName ? NTMI.udkOscServerName;


// check whether default OSCRouter server is reachable:
// (without access, startup can hang for 20-30 secs...)
unixCmd("ping % -c 1".format(NTMI.oscServerName), { |okNum|
	if (okNum == 0) {
		NTMI.oscar = OSCRouterClient(NTMI.myname, "ntmi",
			serverAddr: NTMI.oscServerName,
			userPassword: NTMI.mypwd,
			groupPassword: "senha");
		NTMI.oscar.join;
	} {
		"NTMI.oscar - cannot reach host bgo.la, so we cannot make NTMI.oscar!\n"
		"Replacing with localAddr.".warn;
		NTMI.oscar = NTMI.localAddr;
	}
});

NTMI.statusSkip.stop;
NTMI.statusSkip = SkipJack({
	MFdef(\sendStatus).value;
}, 0.1);

