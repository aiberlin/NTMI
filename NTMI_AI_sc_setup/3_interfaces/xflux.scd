// listen to x-fluences via oscrouter
/*
NTMI.localAddr.sendMsg(\xflux, NTMI.myname, 4, 0.05, 0.5);
*/


NTMI.xflux = NTMI.xflux ? ();
NTMI.xflux.zoom = 1;
NTMI.xflux.influxMode = \setRel;
NTMI.xflux.setRel = {
	"NTMI.xflux.influxMode: \setRel".postln;
};
NTMI.xflux.setAbs = {
	"*** no setAbs! ".post; NTMI.xflux.setRel;
};

// make a dummy MKtl for xflux
// quick and dirty, MKtl(\xflux).gui does not work
MKtl.all.xflux.free;
MKtl(\xflux,
	(idInfo: \xflux, protocol: \dummy, elementsDesc: (elements: [])),
	tryOpenDevice: false
);

// set to true for testing:
NTMI.xflux.sendLocally = true;

(
MFdef(\setRelInf).add(\xflux, { arg ...args;
	// "sending via xflux: %\n".postf(args.round(0.001));
	NTMI.oscar.sendMsg(\xflux, NTMI.myname, *args.flat);
	if (NTMI.xflux.sendLocally) {
		NTMI.localAddr.sendMsg(\xflux, NTMI.myname, *args.flat);
	};
});
);

(
OSCdef(\xflux, {|msg, time, sender|
	var name = msg[1];
	var args = msg[2..];
	var zoom = args.pop;
	var inIndices, diffs;
	#inIndices, diffs = args.clump(args.size/2);
	// "xflux from % - % diffs \n".postf(name, diffs.size);
	// msg.round(0.001).postln;
	MFdef(\setRelInf).funcDict[\set].value(inIndices, diffs, zoom);
}, \xflux);
);
