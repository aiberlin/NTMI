// oscrouter for internet influences

NTMI.localAddr = NetAddr.localAddr;

NTMI.myname = NTMI.myname ? unixCmdGetStdOut("hostname").reject(_ == Char.nl).asSymbol;
NTMI.mypwd = NTMI.mypwd ? "senha";

// check whether default OSCRouter server is reachable:
// (without access, startup can hang for 20-30 secs...)
unixCmd("ping bgo.la -c 1", { |okNum|
	if (okNum == 0) {
		NTMI.oscar = OSCRouterClient(NTMI.myname, "ntmi",
			userPassword: NTMI.mypwd, groupPassword: "senha");
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
