/*
// xflux propagates changeVectors between NTMI setups
on different computers via Internet/OSCRouter.

SENDING:
an interface changes: e.g. uc4, slider 1 steps up by 3
-> setRelInf(chan(s), normDelta(s), uc4.zoom)
-> change goes to local sounds
-> xflux forwards:
----> srcName, chans, deltas, (uc4.zoom * xflux.zoomSend)

RECEIVING:
xflux gets flat array of srcName, chans, deltas, zoom
-> localZoom = zoomFromMsg * zoomListen
-> run local setRelInf without sending

TODO:
- dummy MKtls add complication and confusion... replace or get rid of them?
-> better only the real MKtls, others just have a space in xflux
-> or distuinguish by protocol: xflux

// flags to configure:
NTMI.xflux.sends = true;
NTMI.xflux.sends = false;
NTMI.xflux.listens = true;
NTMI.xflux.listens = false;
NTMI.xflux.verbose = true;
NTMI.xflux.verbose = false;

// send test msg by hand:
NetAddr.localAddr.sendMsg(\xflux, NTMI.myname, 4, 0.05.rand2, 1);

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
			(idInfo: name, protocol: \xflux, elementsDesc: (elements: [])),
			tryOpenDevice: false);
	};
};

NTMI.makeInfluxSource(\xflux);

NTMI.xflux.sends = true;
NTMI.xflux.listens = true;
NTMI.xflux.verbose = true;

NTMI.at(\xflux).zoomListen = 1;
NTMI.at(\xflux).zoomSend = 1;

NTMI.xflux.enable = {
	// off by default
	MFdef(\setRelInf).enable(\xflux);
	OSCdef(\xflux).enable;
};
NTMI.xflux.disable = {
	// off by default
	MFdef(\setRelInf).disable(\xflux);
	OSCdef(\xflux).disable;
};



(
MFdef(\setRelInf).add(\xflux, { arg ...args;
	if (NTMI.xflux.sends) {
		args = args.flat;
		args.putLast(args.last * NTMI.xflux.zoomSend ? 1);
		NTMI.oscar.sendMsg(\xflux, NTMI.myname, *args);
		if (NTMI.xflux.verbose) {
			"xflux sends: %, %\n".postf(NTMI.myname, args.round(0.00001));
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
	var xfluxzoom = NTMI.at(\xflux).zoomListen ? 1;
	var xf_name = "xf_%".format(name).asSymbol;
	var xf_peer_zoom;

	if (NTMI.xflux.listens) {
		if (NTMI.xflux.verbose) {
			"xflux received: %\n".postf(msg.round(0.00001));
		};

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
		MFdef(\setRelInf).valueAt(funcKeys, inIndices, diffs,
			zoom * xfluxzoom * xf_peer_zoom
		);
	}
}, \xflux);
);
