// listen to x-fluences via oscrouter
/*
TODO:
- dummy MKtls add complication and confusion... replace them?
-> better only the real MKtls, others just have a space in xflux
-> or distuinguish by protocol: xflux

- GUI should have:
*** if oscar: oscar status, join but
*** if oscar and xflux :
* xflux send on/off, level
* xflux receive on/off, level
*** local MKtls, with setAbs/setRel if supported
* xflux external sources w separate controls,
and and irrel. buttons off


// set to true for local testing:
NTMI.xflux.sendLocally = true;
NTMI.xflux.sendLocally = false;

// flags to configure:
NTMI.xflux.sends = true;
NTMI.xflux.sends = false;
NTMI.xflux.listens = true;
NTMI.xflux.listens = false;
NTMI.xflux.verbose = true;
NTMI.xflux.verbose = false;

// send test msg by hand:
NetAddr.localAddr.sendMsg(\xflux, NTMI.myname, 4, 0.05, 0.5);
MKtl('xf_adc').timeSinceLast
MFdef(\setRelInf).activeNames

OSCdef.trace(true, true)
OSCdef.trace(false)
*/

NTMI.makeInfluxSource = { |q, name|
	name = name.asSymbol;

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
			(idInfo: name, protocol: \xflux, elementsDesc: (elements: [
				(key: \dummy, elementType: \slider, spec: \unipolar)
			])),
			tryOpenDevice: false);
	};
};

NTMI.xflux = NTMI.xflux ? ();

// Magical number for jitter filter (nUFO / Flatcat)
// 0.0079 is the minimum value of change when using MIDI devices
NTMI.xflux.jitterThreshold = 0.0075;

// NTMI.makeInfluxSource(\xflux);

// set to true for local-only testing:
NTMI.xflux.sendLocally = false;

// only turn these on when using xflux
NTMI.xflux.sends = false;
NTMI.xflux.listens = false;
NTMI.xflux.verbose = false;

(
MFdef(\setRelInf).add(\xflux, { arg ...args;
	if (NTMI.xflux.sends) {
		if (NTMI.xflux.verbose) {
			"xflux sends: %, %\n".postf(NTMI.myname, args.round(0.001));
		};
		//args[1].abs.sum;
		if (args[2] > 0.0 and: {(args[1].asArray.sum(_.abs) * args[2]) > NTMI.xflux.jitterThreshold}) {
			NTMI.oscar.sendMsg(\xflux, NTMI.myname, *args.flat);
			if (NTMI.xflux.sendLocally) {
				NTMI.localAddr.sendMsg(\xflux, NTMI.myname, *args.flat);
			}
		};
	}
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

	if (NTMI.xflux.listens) {
		if (NTMI.xflux.verbose) {
			"xflux received: %\n".postf(msg.round(0.0001));
		};

		if (NTMI.at(xf_name).isNil) {
			// make a dummy MKtl with separate zoom value
			// add it to the InfluxMixer so we can change zoom
			// individually per source.
			NTMI.makeInfluxSource(xf_name);
		};

		xf_peer_zoom = NTMI.at(xf_name).zoom ? 1;

		// set dummy value so we have a timeSinceLast
		MKtl(xf_name).set(\dummy, 0.5);
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
		MFdef(\setRelInf).valueAt(funcKeys, inIndices, diffs,
			zoom * xfluxzoom * xf_peer_zoom
		);
	}
}, \xflux);
);
