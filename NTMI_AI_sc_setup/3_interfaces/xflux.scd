NTMI.xflux = NTMI.xflux ? ();
// set to true for testing:
NTMI.xflux.sendLocally = true;

NTMI.myname = NTMI.myname ? unixCmdGetStdOut("hostname").reject(_ == Char.nl).asSymbol;
NTMI.mypwd = NTMI.mypwd ? "senha";

NTMI.localAddr = NetAddr.localAddr;

// check whether default OSCRouterClient server is reachable:
// (without access, startup can hang for 20-30 secs...)
unixCmd("ping bgo.la -c 1", { |okNum|
	if (okNum == 0) {
		NTMI.oscar = OSCRouterClient(NTMI.myname, "ntmi",
			userPassword: NTMI.mypwd, groupPassword: "senha");
		NTMI.oscar.join;
	} {
		"NTMI.oscar - cannot reach host bgo.la, so we cannot make NTMI.oscar!
Replacing with localAddr.".warn;
		NTMI.oscar = NTMI.localAddr;
	}
});
(
MFdef(\setRelInf).add(\xflux, { arg ...args;
	// "sending xflux: %\n".postf(args.round(0.001));
	NTMI.oscar.sendMsg(\xflux, NTMI.myname, *args.flat);
	if (NTMI.xflux.sendLocally) {
		NTMI.localAddr.sendMsg(\xflux, *args.flat);
	};
});
);

(
OSCdef(\xflux, {|msg|
	var name = msg[1];
	var args = msg[2..];
	var zoom = args.pop;
	var inIndices, diffs;
	#inIndices, diffs = args.clump(args.size/2);
	// "xflux from % - % diffs \n".postf(name, diffs.size);
	// args.round(0.001).postln;
	MFdef(\setRelInf).funcDict[\set].value(inIndices, diffs, zoom);
}, \xflux);
);
