/**** EN16 grid layout for NTMI:

-			1			2			3		4
top row:	mainFX      influxPre   zoom    mainvol, snap

2nd row: slots. bt is toggle play, enc is vol, but + enc = change snd

row 3, 4: encs are influx relatives

row 3 bt: 4x snd preset up
row 4 bt: 4x snd preset down
3 + 4 bt: jump snd preset

m.gui.showLabels;

MFdef.all.skeys
NTMI.skeys.cs

NTMI.at(~en16).setRel
NTMI.at(~en16).setAbs
MKtl(\en16).free;
MKtl.all
m.elAt(\bt, 2)
****/

// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware
var m = NTMI.makeMKtl('en16', "intech-grid", NTMI.currInfo);

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
m.addNamed(\FXstep, m.elAt(\enc, 0));
m.elAt(\FXstep).elemDesc.label = "FXstep";
m.addNamed(\FXjump, m.elAt(\bt, 0, 0));
m.elAt(\FXjump).elemDesc.label = "FXjump";

m.addNamed(\infPre, m.elAt(\enc, 1));
m.elAt(\infPre).elemDesc.label = "infPre";
m.addNamed(\infJmp, m.elAt(\bt, 1, 0));
m.elAt(\infJmp).elemDesc.label = "infJmp";

m.addNamed(\zoom, m.elAt(\enc, 2));
m.elAt(\zoom).elemDesc.label = "zoom";

m.addNamed(\mainVol, m.elAt(\enc, 3));
m.elAt(\mainVol).elemDesc.label = "mainVol";
m.addNamed(\SNAP, m.elAt(\bt, 3, 0));
m.elAt(\SNAP).elemDesc.label = "SNAP";

m.addNamed(\vols, m.elAt(\enc, (4..7)));
m.elAt(\vols).do { |el, i| el.elemDesc.label = "snd% vol".format(i+1) };
m.addNamed(\playBts, m.elAt(\bt, (4..7), 0));
m.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd %".format(i+1) };

m.addNamed(\infl, m.elAt(\enc, (8..15)));
m.elAt(\infl).do { |el, i| el.elemDesc.label = "infl %".format(i+1) };


/// then add actions:
m.elAt(\FXstep).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	// time-buffer this for safety
	MFdef(\mainPreStep).(delta);
};
m.elAt(\FXjump).action = { MFdef(\mainPreStep).value };

m.elAt(\infPre).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	NTMI.inph.stepWPre.(delta);
};
m.elAt(\infJmp).action = { NTMI.inph.stepWPre };


m.elAt(\zoom).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	// if knob down, set NTMI.zoom
	if (m.elAt(\bt, 2).isOn) {
		var spec = \zoom.asSpec;
		var zoomval = spec.unmap(NTMI.zoom);
		var relStep = delta * 0.025;
		zoomval = spec.map(zoomval + relStep);
		NTMI.zoom = zoomval;
		// "NTMI.zoom: %\n".postf(NTMI.zoom);
	} {
		// default: set my interface zoom

		"NTMI.%.zoom: %\n".postf(m.name, NTMI.at(m.name).zoom);
	};
};

m.elAt(\mainVol).action = { |el|
	var delta = el.deviceValue - el.prevDeviceValue.clip(1, 126);
	MFdef(\mainVolStep).(delta);
};
m.elAt(\SNAP).action = { MFdef(\snapshot).value };

m.elAt(\vols).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		// limit to +-6, the largest ever step on an encoder
		var valStep = (el.deviceValue - el.prevDeviceValue).clip2(6);
		MFdef(\ndefVolStep).(ndef, (valStep * 0.4));
	}
};
m.elAt(\playBts).do { |el, i|
	el.action = { NTMI.slots.toggleAt(i) }
};

m.elAt(\infl).do { |el, i|
	el.action = {
		MFdef(\setRelInf).(i + 9, el.value - el.prevValue);
		NTMI.resetOnMinMax(el);
	}
};
