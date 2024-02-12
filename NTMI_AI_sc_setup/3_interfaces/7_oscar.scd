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

How to stop oscar when osc server not reachable?

*/

// the environment for oscrouter
NTMI.oscar = NTMI.oscar ? ();

NTMI.localAddr = NetAddr.localAddr;

NTMI.oscar.sendMsg = { |oscar ... args|
	if (NTMI.oscar.oscar.notNil and: { NTMI.oscar.oscar.hasJoined }) {
		NTMI.oscar.oscar.sendMsg(\slotStatus, NTMI.myname, *args);
	} {
		// "NTMI.oscar.oscar cannot send".postln;
	};
};


NTMI.myname = NTMI.myname ? unixCmdGetStdOut("hostname").reject(_ == Char.nl).asSymbol;
NTMI.mypwd = NTMI.mypwd ? "senha";

// use gencomp oscserver as default
NTMI.oscar.udkServerName = "gencomp.medienhaus.udk-berlin.de";
NTMI.oscServerName = NTMI.oscServerName ? NTMI.oscar.udkServerName;

// if it is reachable, make it:
NTMI.oscar.makeServer = {
	"NTMI.oscar.makeServer };".postln;

	NTMI.oscar.oscar = OSCRouterClient(NTMI.myname, "ntmi",
		serverAddr: NTMI.oscServerName,
		userPassword: NTMI.mypwd,
		groupPassword: "senha"
	).postln;
	fork {
		0.2.wait;
		NTMI.oscar.oscar.join({
			// only start sending when
			NTMI.statusSkip.stop;
			NTMI.statusSkip = SkipJack({
				MFdef(\sendStatus).value;
			}, 0.1);
		});
	};
};

NTMI.oscar.tryReachServer = {
	var pingID, killed = false;
	// check whether default OSCRouter server is reachable:
	// (without access, startup can hang for 20-30 secs...)
	"NTMI.oscar.tryReachServer:".postln;
	pingID = unixCmd("ping % -c 2 -o -t 5".format(NTMI.oscServerName).postln, { |okNum|
		("reachedOkNum:" + okNum).postln;
		("killed: " + killed).postln;
		if (okNum == 0 and: killed.not) {
			"NTMI.oscar: reached server %, so making NTMI.oscar.oscar.\n"
			.postf(NTMI.oscServerName);
			defer { NTMI.oscar.makeServer };
		} {
			"*** NTMI.oscar: server unreachable, not making make NTMI.oscar!\n".postln;
		};
	});
	defer ({
		unixCmd("kill %".format(pingID), { |res|
			killed = true; "NTMI.oscar:  2 sec".postln
	}) }, 2);
};

NTMI.oscar.tryReachServer;

