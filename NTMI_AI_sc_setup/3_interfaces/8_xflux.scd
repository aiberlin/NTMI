// listen to x-fluences via oscrouter
/*
// set to true for local testing:
NTMI.xflux.sendLocally = true;
NTMI.xflux.sendLocally = false;
// send test msg by hand:
NTMI.localAddr.sendMsg(\xflux, NTMI.myname, 4, 0.05, 0.5);

MFdef(\setRelInf).activeNames

currently, this just sends changeVectors.
how to send changeSteps?
- for slots - toggle, volume, sound, preset?
- for influxweights, mainvol, mainfx presets too?
- zoom should probably stay local

// like this?
NTMI.localAddr.sendMsg(\change, NTMI.myname, \mainVol, step);
NTMI.localAddr.sendMsg(\change, NTMI.myname, \mainFXPre, step);
NTMI.localAddr.sendMsg(\change, NTMI.myname, \slotTog, index);
NTMI.localAddr.sendMsg(\change, NTMI.myname, \slotVol, index, step);
NTMI.localAddr.sendMsg(\change, NTMI.myname, \slotSnd, index, step);
NTMI.localAddr.sendMsg(\change, NTMI.myname, \slotPre, index, step);
NTMI.localAddr.sendMsg(\change, NTMI.myname, \infWPre, step);
// unify - include setRelInf?
NTMI.localAddr.sendMsg(\change, NTMI.myname, \setRelInf, inIndices, diffs, zoom);

OSCdef.trace(true, true)
OSCdef.trace(false)
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
NTMI.xflux.sendLocally = false;


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
	var vals = msg[2..];
	var inIndices, diffs, zoom;
	var funcKeys = MFdef(\setRelInf).activeNames.reject(_ == \xflux);

	// "vals.size: %\n".postf(vals.size);
	if (vals.size.even) {
		"xflux - even size of incoming values?\n"
		"assuming zoom is missing and should be 1.".postln;
		zoom = 1;
	} {
		// all is well:
		zoom = vals.pop;
		#inIndices, diffs = vals.clump(vals.size.div(2));
	};

	// "xflux from % - % diffs:\n".postf(name, diffs.size);
	// "inIndices: % \n diffs: %\nzoom: %\n".postf(inIndices, diffs, zoom);
	MFdef(\setRelInf).valueAt(funcKeys, inIndices, diffs, zoom);
}, \xflux);
);
