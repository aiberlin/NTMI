/**** EN16 grid layout for NTMI:

-				1			2			3			4
top row enc	rotate thru rotate      local or 	mainvol
			mainFX      influxPre   glob. zoom
top button: preset mode snd mode    hold for glob  SNAP


2nd row: 4x slots:
		bt is toggle play/stop,
		basic -> enc is vol;
		if top left bt is down,
		-> encoder chooses preset;
		if top sec bt is down,
		-> encoder chooses sound process.

row 3, 4: encs relative-set influx channels

row 3 buttons: 4x de/couple to/from influx
row 4 buttons: 4x randomize sound settings


// todo: check whetehr setting deviceValue works on ec4:
// m.elAt(0, \kn).deviceValue = 64;

****/

// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware

var m;
m = NTMI.makeMKtl(\ec4, "*ec4_basic", NTMI.currInfo);
m.gui.showLabels;

m.addHalo(\zoom, 1);
m.addSpec(\zoom, [0, 4, \amp]);
NTMI.put(m.name, m.getHalo);

m.getHalo.putAll((
	influxMode: \setRel,
	setAbs: { |dict|
		"*** % only has setRel.\n".postf(m);
		dict.influxMode = \setRel;
	},
	setRel: { "*** % is always setRel.\n".postf(m) },
	zoom: 1,
	butDown: Set[],
	butsUsedForMode: false
));

// name them first:
m.addNamed(\FXstep, m.elAt(0, \kn, 0));
m.elAt(\FXstep).elemDesc.label = "FXstep";

m.addNamed(\_pre, m.elAt(0, \hat, 0, 0));
m.elAt(\_pre).elemDesc.label = "_pre";

m.addNamed(\infPre, m.elAt(0, \kn, 1));
m.elAt(\infPre).elemDesc.label = "infPre";
m.addNamed(\_snd, m.elAt(0, \hat, 1, 0));
m.elAt(\_snd).elemDesc.label = "_snd";

m.addNamed(\zoom, m.elAt(0, \kn, 2));
m.elAt(\zoom).elemDesc.label = "zoom";

m.addNamed(\mainVol, m.elAt(0, \kn, 3));
m.elAt(\mainVol).elemDesc.label = "mainVol";
m.addNamed(\SNAP, m.elAt(0, \hat, 3, 0));
m.elAt(\SNAP).elemDesc.label = "SNAP";

m.addNamed(\vols, m.elAt(0, \kn, (4..7)));
m.elAt(\vols).do { |el, i| el.elemDesc.label = "snd% vol".format(i+1) };
m.addNamed(\playBts, m.elAt(0, \hat, (4..7), 0));
m.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd %".format(i+1) };

m.addNamed(\coupBts, m.elAt(0, \hat, (8..11), 0));
m.elAt(\coupBts).do { |el, i| el.elemDesc.label = "d/cp%".format(i+1) };

m.addNamed(\randBts, m.elAt(0, \hat, (12..15), 0));
m.elAt(\randBts).do { |el, i| el.elemDesc.label = "RAND".format(i+1) };

m.addNamed(\infl, m.elAt(0, \kn, (8..15)));
m.elAt(\infl).do { |el, i| el.elemDesc.label = "infl %".format(i+1) };


/// then add actions:
m.elAt(\FXstep).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	// time-buffer this for safety
	MFdef(\mainPreStep).(delta);
};

m.elAt(\infPre).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	NTMI.inph.stepWPre.(delta);
};

// second row encoders are modal:
// normally, they change volume;
// when top left but is down, they change preset;
// when top second but is down, they change sound;
m.elAt(\zoom).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
		var relStep = delta * 0.025;
	// if knob down, set NTMI.zoom
	if (m.elAt(0, \hat, 2).isOn) {
		var spec = \zoom.asSpec;
		var zoomval = spec.unmap(NTMI.zoom);
		zoomval = spec.map(zoomval + relStep);
		NTMI.zoom = zoomval;
		"NTMI.zoom: %\n".postf(NTMI.zoom);
	} {
		// default: set my interface zoom
		var spec = m.getSpec(\zoom);
		var zoomval = spec.unmap(NTMI.at(m.name).zoom);
		var relStep = (delta * 0.01);
		zoomval = spec.map(zoomval + relStep);
		NTMI.at(m.name).zoom = zoomval;
		"NTMI.%.zoom: %\n".postf(m.name, NTMI.at(m.name).zoom);
	};
};

m.elAt(\mainVol).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	MFdef(\mainVolStep).(delta);
};
m.elAt(\SNAP).action = { MFdef(\snapshot).value };

/// lower 4 knobs change slots volume, preset or sound
m.elAt(\vols).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		// limit to +-6, the largest ever step on an encoder
		var valStep = (el.deviceValue - el.prevDeviceValue).clip2(6);

		case { m.elAt(\_pre).parent.isOn } {
			NTMI.pre.stepNdefInf(ndef, valStep);
		} { m.elAt(\_snd).parent.isOn } {
			NTMI.slots.stepNext(i, valStep);
		} {
			// default: vol
			MFdef(\ndefVolStep).(ndef, (valStep * 0.4));
		};
		// reset if we hit maxval or minval
		NTMI.resetOnMinMax(el);
	}
};

m.elAt(\playBts).do { |el, i|
	el.action = { NTMI.slots.toggleAt(i) }
};

m.elAt(\coupBts).do { |el, i|
	el.action = {
		NTMI.inph.clutch(NTMI.ndefs[i])
	}
};

m.elAt(\randBts).do { |el, i|
	el.action = {
		NdefPreset(NTMI.ndefs[i]).setRand(1.0)
	}
};

m.elAt(\infl).do { |el, i|
	el.action = { |el|
		var valStep = (el.deviceValue - el.prevDeviceValue).clip2(6);
		MFdef(\setRelInf).([i + 9], [valStep * 0.01], m.getHalo.zoom);
	}
};

// return m
m;