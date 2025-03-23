/******* UC4 setup for NTMI:

- top 4 knobs:
--					scroll thru presets
-- 					if hat held down, scroll thru sounds

- lower 4 knobs  		change slots volume / relative
- lower 4 hat-buttons 	toggle sound slots on/off

- 8 sliders: 		all influx!

- xfader:           mainVol via mainVol param

- bot buts 1 2 3:	rand, prev, next influx preset
- bot but  5:		snapshot presets
- bot buts 6 7 8:	rand, prev, next mainFX preset
- bot but 4 		set nflux to zero if needed

//// while you can switch encoder to relative,
//// we keep them on default for this setup!
*/


/*
// flexify name in order to build multiple MKtls with this file:
// TEST:
NTMI.currInfo = (mktlName: \karl);
NTMI.makeMKtl(\uc4, "*uc4_pg", NTMI.currInfo);
MKtl.all.karl.gui
MKtl.all.uc4.gui
MKtl.all.uc4.free;
*/

// Use makeMKtl and NTMI.currInfo to support multiple hardware MKtls:
// arguments:MKtl name, desc filename, info reg. multiple hardware
var m = NTMI.makeMKtl(\uc4, "*uc4_pg", NTMI.currInfo);

// make all named elements first
m.addNamed(\main, m.elAt(\xfader));
m.addNamed(\inflx, m.elAt(\pgSl1, \sl));

// lower 4 encoders and their hatButtons for play and vol
m.addNamed(\vols, m.elAt(\pgKn1, \kn, (4..7)));
m.addNamed(\playBts, m.elAt(\pgKn1, \pbt, (4..7), 0));

// higher 4 encoders for changing presets, hold hats for processes
// select preset or sounds
m.addNamed(\select, m.elAt(\pgKn1, \kn, (0..3)));
// if but up, select preset, if down, sound
m.addNamed(\selMode, m.elAt(\pgKn1, \pbt, (0..3)));

m.addNamed(\prev_inph, m.elAt(\pgSl1, \bt, 0, 0));
m.addNamed(\rand_inph, m.elAt(\pgSl1, \bt, 1, 0));
m.addNamed(\next_inph, m.elAt(\pgSl1, \bt, 2, 0));
m.addNamed(\zero_inph, m.elAt(\pgSl1, \bt, 3, 0));

// use record button for snapshots
m.addNamed(\snap, m.elAt(\pgSl1, \bt, 4, 0));

m.addNamed(\prev_pre, m.elAt(\pgSl1, \bt, 5, 0));
m.addNamed(\rand_pre, m.elAt(\pgSl1, \bt, 6, 0));
m.addNamed(\next_pre, m.elAt(\pgSl1, \bt, 7, 0));


// modify labels, use only semantic element names:
m.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
m.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

m.elAt(\select).do { |el, i| el.elemDesc.label = "select".format(i+1) };
m.elAt(\selMode).do { |el, i| el.elAt(0).elemDesc.label = "^-pre v-snd".format(i+1) };

m.elAt(\inflx).do { |sl, i| sl.elemDesc.label = "inf" + NTMI.inphlux.inNames[i].cs };

m.elAt(\main).elemDesc.label = "Main Vol";

m.elAt(\rand_inph).elemDesc.label = "rand inph";
m.elAt(\prev_inph).elemDesc.label = "prev inph";
m.elAt(\next_inph).elemDesc.label = "next inph";
m.elAt(\zero_inph).elemDesc.label = "zero inph";


m.elAt(\snap).elemDesc.label = "snap pre!";
m.elAt(\rand_pre).elemDesc.label = "rand MFX";
m.elAt(\prev_pre).elemDesc.label = "prev MFX";
m.elAt(\next_pre).elemDesc.label = "next MFX";


// init values
m.elAt('pgKn1', \kn).value = 0.5;
m.elAt('pgSl1', \sl).value = 0.5;
m.elAt('main').value = 0.5;



// *** add local settings and functions to uc4 ***
// local zoom value:
m.addSpec(\zoom, [0, 4, \amp]);
m.addHalo(\zoom, 1);


// allow direct access of halo via NTMI:
NTMI.put(m.name, m.getHalo);
// and access like this
m.getHalo.zoom.postln;

// flag whether to use influx in relative or absolute mode:
// (there could be more modes, e.g. softAbs ...)
m.getHalo.influxMode = \setRel;

// set functions for the two supported modes:
m.getHalo.setRel = {
	m.getHalo.influxMode = \setRel;
	"uc4 influxMode is now: %\n.".postf(\setRel);
};

m.getHalo.setAbs = {
	m.getHalo.influxMode = \setAbs;
	"uc4 influxMode is now: %\n.".postf(\setAbs);
};
// read and set:
m.getHalo.influxMode;
m.getHalo.setRel;


/// lower 4 knobs change slots volume
m.elAt(\vols).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		// limit to +-6, the largest ever step on an encoder
		var valStep = NTMI.encDelta(el);
		MFdef(\ndefVolStep).(ndef, (valStep * 0.4));
	}
};

/// lower 4 buttons toggle sound slots on/off
m.elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.value > 0) { NTMI.slots.toggleAt(i) }
	};
};

// xfader is main volume before limiter
m.elAt('main').action = { |xf|
	////// set server volume directly:
	// 	s.volume.volume_(\svol.asSpec.map(xf.value))
	////// set mainVol in absolute mode:
	// 	MFdef(\mainVolSetUni).value(xf.value);
	// best: step mainVol according to slider move
	MFdef(\mainVolStep).value(xf.deviceValue - xf.prevDeviceValue);
};

/* top line buttons are modal:
// click and release toggles de/coupling slot
m.elAt('selMode', 0, \on).valueAction_(1);
m.elAt('selMode', 0, \off).valueAction_(0);

// click and turn hat: sound changes, no decoupling
m.elAt('selMode', 0, \on).valueAction_(1);
m.elAt(\select, 0).deviceValueAction_(43.rand);
m.elAt('selMode', 0, \off).valueAction_(1);
*/

m.elAt('selMode').do { |onoffgroup, i|
	onoffgroup[0].action = {
		"prepare % for modal use\n".postf(i);
		onoffgroup.addHalo(\wasUsed, false);
	};
	onoffgroup[1].action = {
		if (onoffgroup.getHalo(\wasUsed).not) {
			var ndef = NTMI.slots.actives[i];
			if(NTMI.inph.decoupled.includes(ndef.key)) {
				"couple slot % \n".postf(i);
				NTMI.inph.couple(ndef)
			} {
				"decouple slot % \n".postf(i);
				NTMI.inph.decouple(ndef)
			};
			NTMI.inph.decoupled.postln;
		}
	}
};

// normal: select next setting
// hat down: select next sound

m.elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		var relStep = NTMI.encDelta(el);
		var onoffbut = m.elAt(\selMode)[i];

		if (onoffbut.isOn) {
			onoffbut.addHalo(\wasUsed.postln, true);
			// next sound
			NTMI.slots.stepNext(i, relStep);
		} {
			// next preset
			NTMI.pre.stepNdefInf(ndef, relStep);
		};
	}
};



// bt5, snapshots presets of all currently playing sounds
m.elAt(\snap).action = { |el|
	if (el.isOn) {
		MFdef(\snapshot).value;
	}
};

/*
which influx input offsets to use?
amptweaked ins are are 8 (nUFO nose up/down),
and 10 (nUFO left mid finger power)
and 14 (nUFO right mid finger, break).
so with offset 1, last slider becomes amp control,
but all sliders overlap with nUFO ...
-> for nufo setups, use offset 9, for non-nufo, use offset 1
*/
m.getHalo.sliderOffset = m.getHalo.sliderOffset ? 1;

m.elAt(\inflx).do { |sl, i|
	sl.action = { |sl|
		if (m.getHalo.influxMode == \setAbs) {
			var name = NTMI.inphlux.inNames[i + m.getHalo.sliderOffset];
			NTMI.inphlux.set(name, sl.value.unibi * m.getHalo.zoom);
		} {
			MFdef(\setRelInf).(
				i + NTMI.inph.sliderOffset,
				(sl.prevValue - sl.value).clip2(0.05),
				NTMI.zoom * m.getHalo.zoom
			)
		}
	}
};

// Left 3 bottom buttons: inphPre rand, -1, +1
m.elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
m.elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
m.elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };
m.elAt(\zero_inph).action = { |el| if (el.isOn) { NTMI.inphlux.resetInvals } };


// Right 3 bottom buttons: mainfx preset rand, -1, +1
m.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
m.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
m.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

/**** add UC4 page2 - direct mode:
8 sliders on page2 PullSet set first 8 process params
hold down pgSl2 bt_1 to get params 9-16
************/

m.elAt('pgSl2', \sl).do { |sl, i|
	sl.action = { |sl|
		var index = m.elAt('pgSl2', \bt, 0).isOn.binaryValue * 8 + i;
		// [sl.name, sl.value.round(0.001)].postln;
		NTMI.slots.nowPlaying.do { |ndef|
			var paramKey = ndef.controlKeys[index];
			if (paramKey.notNil) {
				ndef.setUni(paramKey, sl.value);
			};
		};
	};
};

m;