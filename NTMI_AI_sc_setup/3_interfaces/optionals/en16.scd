/**** EN16 grid layout for NTMI:

top row encoders:
left : rotate thru mainFX    local or
2nd  : rotate thru influxPreset
3rd  : zoom: local ec4 zoom, or click-hold and turn for global zoom
right: main volume

top row buttons:
left : hold to make 2nd row knobs change sound presets
2nd  : hold to make 2nd row knobs change sound processes
3rd  : hold to make this encoder change global zoom
right: press to store snapshot presets for all playing sounds

2nd row: functions for the 4 slots:
- button toggles play/stop,
- encoder base mode: change slot sound volume
-- if top left bt is down -> encoder chooses sound preset;
-- if top 2nd  bt is down -> encoder chooses sound process.

row 3, 4: encoders do relative-set 8 influx channels

row 3 buttons: 4x de/couple from/to influx
row 4 buttons: 4x randomize sound settings


// todo: figure out how to set deviceValue on en16!
// ATM, this does not work:
// m.elAt(\enc).deviceValue = 64;

****/

// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware
var m;

m = NTMI.makeMKtl('en16', "intech-grid", NTMI.currInfo);


// name them first:
m.addNamed(\FXstep, m.elAt(\enc, 0));
m.elAt(\FXstep).elemDesc.label = "FXstep";

m.addNamed(\_pre, m.elAt(\bt, 0, 0));
m.elAt(\_pre).elemDesc.label = "_pre";

m.addNamed(\infPre, m.elAt(\enc, 1));
m.elAt(\infPre).elemDesc.label = "infPre";
m.addNamed(\_snd, m.elAt(\bt, 1, 0));
m.elAt(\_snd).elemDesc.label = "_snd";

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

m.addNamed(\coupBts, m.elAt(\bt, (8..11), 0));
m.elAt(\coupBts).do { |el, i| el.elemDesc.label = "d/cp%".format(i+1) };

m.addNamed(\randBts, m.elAt(\bt, (12..15), 0));
m.elAt(\randBts).do { |el, i| el.elemDesc.label = "RAND".format(i+1) };

m.addNamed(\infl, m.elAt(\enc, (8..15)));
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
	if (m.elAt(\bt, 2).isOn) {
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