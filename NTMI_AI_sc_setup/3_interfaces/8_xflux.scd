// listen to x-fluences via oscrouter
/*
// set to true for local testing:
NTMI.xflux.sendLocally = true;
NTMI.xflux.sendLocally = false;
// send test msg by hand:
NTMI.localAddr.sendMsg(\xflux, NTMI.myname, 4, 0.05, 0.5);

MFdef(\setRelInf).activeNames

OSCdef.trace(true, true)
OSCdef.trace(false)
*/

NTMI.makeInfluxSource = { |q, name|
	if (NTMI.at(name).notNil) {
		"cannot make influx source, name % exists".format(name).warn;
	} {
		NTMI.put(name, (
			zoom: 1,
			influxMode: \setRel,
			setRel: { |dict| dict.influxMode = \setRel },
			setAbs: { |dict| dict.setRel }
		));
		MKtl.all[name].free;
		MKtl(name,
			(idInfo: name, protocol: \dummy, elementsDesc: (elements: [])),
			tryOpenDevice: false);
	};
};

NTMI.makeInfluxSource(\xflux);

// set to true for testing:
NTMI.xflux.sendLocally = false;


(
MFdef(\setRelInf).add(\xflux, { arg ...args;
	// "sending via xflux: %\n".postf(args.round(0.001));
	NTMI.oscar.oscar.sendMsg(\xflux, NTMI.myname, *args.flat);
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
	var xfluxzoom = NTMI.at(\xflux).zoom ? 1;
	var xf_name = "xf_%".format(name).asSymbol;
	var xf_peer_zoom;
	// msg.round(0.001).postln;


	if (NTMI.at(xf_name).isNil) {
		// make a dummy MKtl with separate zoom value
		// add it to the InfluxMixer so we can change zoom
		// individually per source.
		NTMI.makeInfluxSource(xf_name);
	};

	xf_peer_zoom = NTMI.at(xf_name).zoom ? 1;

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
	MFdef(\setRelInf).valueAt(funcKeys, inIndices, diffs, zoom * xfluxzoom * xf_peer_zoom);
}, \xflux);
);
