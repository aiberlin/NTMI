/*
OscRouter for internet influences:

all NTMIs can send to an OSCRouter server,
which relays messages to other running NTMIs.
The first use of these is the changeVectors
created by local interfaces in setRel mode,
which go to influence all running processes
as the source 'xflux'.

When OSCRouter address cannot be reached,
e.g. when using nUFO local network, or generally not internet connection,
NTMI.oscar should not try to join, to avoid network error messages.

NTMI.oscar.close;
NTMI.oscar.join;



*/

// the environment for oscrouter
NTMI.oscar = NTMI.oscar ? ();
NTMI.oscar.verbose = false;

NTMI.myname = NTMI.myname ? unixCmdGetStdOut("hostname").reject(_ == Char.nl).asSymbol;
NTMI.mypwd = NTMI.mypwd ? "senha";

// use gencomp oscserver as default
// "gencomp.medienhaus.udk-berlin.de".gethostbyname.asIPString;
NTMI.oscar.udkServerName = "gencomp.medienhaus.udk-berlin.de";
NTMI.oscar.udkServerIP = NTMI.oscar.udkServerIP ? "194.95.202.114";

///// testIP does not work properly yet:
///// when in nUFO or flatcat network,
// .testIP returns true even though it cannot reach the online server
NTMI.oscar.testIP = {
	NTMI.oscar.reachedServer = false;
	try {
		NetAddr(NTMI.oscar.udkServerIP, 57120).sendMsg(\test);
		NTMI.oscar.reachedServer = true;
	};
	NTMI.oscar.reachedServer
};


// always use NTMI.oscar.sendMsg wrapper:
// will quietly dummy-send when network drops out
NTMI.oscar.sendMsg = { |oscar ... args|
	if (NTMI.oscar.oscar.notNil and: { NTMI.oscar.oscar.hasJoined }) {
		NTMI.oscar.oscar.sendMsg(*args);
	} {
		if (NTMI.oscar.verbose) {
			"NTMI.oscar.oscar cannot send ATM".postln
		};
	};
};

NTMI.oscar.quit = {
	try {
		NTMI.oscar.oscar.close;
		NTMI.oscar.oscar = nil;
	};
};

// if it is reachable, make it:
NTMI.oscar.makeServer = {
	"NTMI.oscar.makeServer".postln;

	if (NTMI.oscar.testIP.not ) {
		"*** NTMI.oscar: cannot start, because serverIP not reached.".postln;
	} {
		NTMI.oscar.oscar = OSCRouterClient(NTMI.myname, "ntmi",
			serverAddr: NTMI.oscar.udkServerIP,
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
				"*** NTMI.oscar is UP!".postln;
			});
		}
	}
};
