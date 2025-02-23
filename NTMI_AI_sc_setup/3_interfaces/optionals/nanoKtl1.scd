/*
This file is for the KORG nanoKontrol1.

-------- THE LAYOUT: ----------
- left knobs 1-4  		change slots volume (with softVol takeover)
- bottom buttons 1-4 	toggle sound slots on/off

- knobs 5-8 		select presets or sounds
-- button 5-8 up	scroll thru presets
-- button 5-8 down	scroll thru sounds

- sliders 1-8: 	influx!

- last slider 9:	mainVol via mainVol

transport buttons:
nk1: rew, play, fwd:	rand, prev, next influx preset
nk1: loop, stop, rec:  rand, prev, next MainFX preset

***********/

/*
// flexify name in order to build multiple MKtls with this file:
// TEST:
m.gui
*/

// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware
var m = NTMI.makeMKtl(\nanoKtl1, "KORG-nanoKONTROL", NTMI.currInfo);

// make all named elements first
m.addNamed(\main, m.elAt(\sl, 0, 8));
m.addNamed(\inflSet, m.elAt(\sl, 0, (0..7)));

m.addNamed(\vols, m.elAt(\kn, 0, (0..3)));
m.addNamed(\playBts, m.elAt(\bt, 0, 1, (0..3)));

// select preset or sounds
m.addNamed(\select, m.elAt(\kn, 0, (4..7)));
// if but up, select preset, if down, sound
m.addNamed(\selMode, m.elAt(\bt, 0, 1, (4..7)));

m.addNamed(\rand_inph, m.elAt(\tr, \rew));
m.addNamed(\prev_inph, m.elAt(\tr, \play));
m.addNamed(\next_inph, m.elAt(\tr, \fwd));

m.addNamed(\rand_pre, m.elAt(\tr, \loop));
m.addNamed(\prev_pre, m.elAt(\tr, \stop));
m.addNamed(\next_pre, m.elAt(\tr, \rec));

// *** add local settings and functions to nanoKtl ***
// local zoom value:
m.addSpec(\zoom, [0, 4, \amp]);
m.addHalo(\zoom, 1);

// allow direct access of halo via NTMI:
NTMI.q.put(m.name, m.getHalo);
// and access like this
m.getHalo.zoom.postln;

// flag whether to use influx in relative or absolute mode:
// (there could be more modes, e.g. softAbs ...)
m.getHalo.influxMode = \setRel;

// set functions for the two supported modes:
m.getHalo.setRel = {
	m.getHalo.influxMode = \setRel;
	"nanoKtl1 influxMode is now: %\n.".postf(\setRel);
};
m.getHalo.setAbs = {
	m.getHalo.influxMode = \setAbs;
	"nanoKtl1 influxMode is now: %\n.".postf(\setAbs);
};
// read and set:
m.getHalo.influxMode;
m.getHalo.setRel;

m.elAt(\inflSet).do(_.value = 0.5);

m.elAt(\main).elemDesc.label = "Main Vol";

m.elAt(\rand_inph).elemDesc.label = "rand inph";
m.elAt(\prev_inph).elemDesc.label = "prev inph";
m.elAt(\next_inph).elemDesc.label = "next inph";

m.elAt(\rand_pre).elemDesc.label = "rand MFX";
m.elAt(\prev_pre).elemDesc.label = "prev MFX";
m.elAt(\next_pre).elemDesc.label = "next MFX";

// modify labels:
m.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
m.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

m.elAt(\selMode).do { |el, i| el.elemDesc.label = "mod sl%".format(i+1) };
m.elAt(\select).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

m.elAt(\inflSet).do { |sl, i| sl.elemDesc.label = "inf" + NTMI.inphlux.inNames[i].cs };


/// left top 4 knobs change slots volume
m.elAt(\vols).do { |el, i|
	el.action = { |el|
		NTMI.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
	};
};

// left bottom 4 buttons toggle sound slots on/off
m.elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.isOn) { NTMI.slots.toggleAt(i) }
	};
};

m.elAt(\inflSet).do { |sl, i|
	sl.action = { |sl|
		// add sliderOffset + 1, so we get to channel 8 for amp tweak
		var inphInIndex = NTMI.inph.sliderOffset + 1 + i;

		if (NTMI.nanoKtl.influxMode == \setAbs) {
			var name = NTMI.inphlux.inNames[i];
			\setAbs.postln;
			NTMI.inphlux.set(name, sl.value.unibi * NTMI.nanoKtl.zoom);
		} {
			// setRel, also default
			MFdef(\setRelInf).(inphInIndex,
				(sl.prevValue - sl.value).clip2(0.05),
				NTMI.zoom * NTMI.nanoKtl.zoom
			)
		}
	}
};

// rightmost slider is main volume (into limiter)
// rightmost slider is main volume (into limiter)
m.elAt(\main).action = { |sl|
	////// set mainVol in absolute mode:
	// 	MFdef(\mainVolSetUni).value(sl.value);
	// best: step mainVol according to slider move
	MFdef(\mainVolStep).value(sl.deviceValue - sl.prevDeviceValue);
};
m.elAt(\main).value = 0.5;

// normal: select next setting
// hat down: select next sound
m.elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		if (m.elAt(\selMode)[i].isOn) {
			// next sound
			NTMI.slots.stepNext(i, relStep);
		} {
			// next preset
			NTMI.pre.stepNdefInf(ndef, relStep);
		};
	};
};

m.elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
m.elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
m.elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };

m.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
m.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
m.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

// snapshot
m.elAt(\bt, 0, 0, 8).elemDesc.label = "snap pre!";
m.elAt(\bt, 0, 0, 8).action = { |el| if (el.isOn, MFdef(\snapshot)) };

m;
