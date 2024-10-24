/**** EN16 grid layput for NTMI:

top row 1:     enc mainFX      enc influxPre          3: zoom         4: mainvol, snap

2nd row 2: bt is play, enc is vol, but + enc = change snd

sls row 3, 4: influx relatives

3 bt:  snd presets up x 4
4 bt:  snd pre down x 4
3 + 4 : jump snd preset

m.gui.showLabels;

MFdef.all.skeys
NTMI.skeys.cs

****/

// if not set, use default name
~en16 = ~en16 ? 'en16';

MKtl.all[~en16].free;
m = MKtl(~en16, "intech-grid");

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
	// time-buffer this for safety
	MFdef(\mainPreStep).(el.deviceValue - el.prevDeviceValue);
};
m.elAt(\FXjump).action = { MFdef(\mainPreStep).value };

m.elAt(\infPre).action = { |el|
	NTMI.inph.stepWPre.(el.deviceValue - el.prevDeviceValue);
};
m.elAt(\infJmp).action = { NTMI.inph.stepWPre };

m.elAt(\zoom).action = {
	"which zoom to set here?".postln;
};

m.elAt(\mainVol).action = { |el|
	MFdef(\mainVolStep).(el.deviceValue - el.prevDeviceValue);
};
m.elAt(\SNAP).action = { MFdef(\snapshot).value };

m.elAt(\vols).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		// limit to +-6, the largest ever step on an encoder
		var valStep = (el.deviceValue - el.prevDeviceValue).clip2(6);
		MFdef(\ndefVolStep).(ndef, (valStep * 0.4));
		// make encoder endless with small jump back;
		// defer is needed for uc4 to accept new value
		(    0: { defer ({ el.deviceValue_(7).trySend }, 0.03) },
			127: { defer ({ el.deviceValue_(120).trySend }, 0.03) }
		)[el.deviceValue].value;
	}
};
m.elAt(\playBts).do { |el, i|
	el.action = { NTMI.slots.toggleAt(i) }
};

m.elAt(\infl).do { |el, i|
	el.action = {
		MFdef(\setRelInf).(i + 9, el.value - el.prevValue);
		// defer is needed for uc4 to accept new value
		(    0: { defer ({ el.deviceValue_(7).trySend }, 0.03) },
			127: { defer ({ el.deviceValue_(120).trySend }, 0.03) }
		)[el.deviceValue].value;
	}
};

