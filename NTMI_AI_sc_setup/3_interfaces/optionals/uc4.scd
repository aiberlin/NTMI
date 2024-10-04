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
~uc4 = \karl; // then run file ...
MKtl.all.karl.gui
MKtl.all.uc4.gui
*/
// if not set, use default name
~uc4 = ~uc4 ? 'uc4';


MKtl.all[~uc4].free; MKtl(~uc4, "*uc4_pg");


// make all named elements first
MKtl(~uc4).addNamed(\main, MKtl(~uc4).elAt(\xfader));
MKtl(~uc4).addNamed(\inflx, MKtl(~uc4).elAt(\pgSl1, \sl));

// lower 4 encoders and their hatButtons for play and vol
MKtl(~uc4).addNamed(\vols, MKtl(~uc4).elAt(\pgKn1, \kn, (4..7)));
MKtl(~uc4).addNamed(\playBts, MKtl(~uc4).elAt(\pgKn1, \pbt, (4..7), 0));

// higher 4 encoders for changing presets, hold hats for processes
// select preset or sounds
MKtl(~uc4).addNamed(\select, MKtl(~uc4).elAt(\pgKn1, \kn, (0..3)));
// if but up, select preset, if down, sound
MKtl(~uc4).addNamed(\selMode, MKtl(~uc4).elAt(\pgKn1, \pbt, (0..3)));

MKtl(~uc4).addNamed(\prev_inph, MKtl(~uc4).elAt(\pgSl1, \bt, 0, 0));
MKtl(~uc4).addNamed(\rand_inph, MKtl(~uc4).elAt(\pgSl1, \bt, 1, 0));
MKtl(~uc4).addNamed(\next_inph, MKtl(~uc4).elAt(\pgSl1, \bt, 2, 0));
MKtl(~uc4).addNamed(\zero_inph, MKtl(~uc4).elAt(\pgSl1, \bt, 3, 0));

// use record button for snapshots
MKtl(~uc4).addNamed(\snap, MKtl(~uc4).elAt(\pgSl1, \bt, 4, 0));

MKtl(~uc4).addNamed(\prev_pre, MKtl(~uc4).elAt(\pgSl1, \bt, 5, 0));
MKtl(~uc4).addNamed(\rand_pre, MKtl(~uc4).elAt(\pgSl1, \bt, 6, 0));
MKtl(~uc4).addNamed(\next_pre, MKtl(~uc4).elAt(\pgSl1, \bt, 7, 0));


// modify labels, use only semantic element names:
MKtl(~uc4).elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
MKtl(~uc4).elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

MKtl(~uc4).elAt(\select).do { |el, i| el.elemDesc.label = "select".format(i+1) };
MKtl(~uc4).elAt(\selMode).do { |el, i| el.elAt(0).elemDesc.label = "^-pre v-snd".format(i+1) };

MKtl(~uc4).elAt(\inflx).do { |sl, i| sl.elemDesc.label = "inf" + NTMI.inphlux.inNames[i].cs };

MKtl(~uc4).elAt(\main).elemDesc.label = "Main Vol";

MKtl(~uc4).elAt(\rand_inph).elemDesc.label = "rand inph";
MKtl(~uc4).elAt(\prev_inph).elemDesc.label = "prev inph";
MKtl(~uc4).elAt(\next_inph).elemDesc.label = "next inph";
MKtl(~uc4).elAt(\zero_inph).elemDesc.label = "zero inph";


MKtl(~uc4).elAt(\snap).elemDesc.label = "snap pre!";
MKtl(~uc4).elAt(\rand_pre).elemDesc.label = "rand MFX";
MKtl(~uc4).elAt(\prev_pre).elemDesc.label = "prev MFX";
MKtl(~uc4).elAt(\next_pre).elemDesc.label = "next MFX";


// init values
MKtl(~uc4).elAt('pgKn1', \kn).value = 0.5;
MKtl(~uc4).elAt('pgSl1', \sl).value = 0.5;
MKtl(~uc4).elAt('main').value = 0.5;



// *** add local settings and functions to uc4 ***
// local zoom value:
MKtl(~uc4).addSpec(\zoom, [0, 4, \amp]);
MKtl(~uc4).addHalo(\zoom, 1);


// allow direct access of halo via NTMI:
NTMI.put(~uc4, MKtl(~uc4).getHalo);
// and access like this
NTMI.at(~uc4).zoom.postln;

// flag whether to use influx in relative or absolute mode:
// (there could be more modes, e.g. softAbs ...)
NTMI.at(~uc4).influxMode = \setRel;

// set functions for the two supported modes:
NTMI.at(~uc4).setRel = {
	MKtl(~uc4).getHalo.influxMode = \setRel;
	"uc4 influxMode is now: %\n.".postf(\setRel);
};

NTMI.at(~uc4).setAbs = {
	MKtl(~uc4).getHalo.influxMode = \setAbs;
	"uc4 influxMode is now: %\n.".postf(\setAbs);
};
// read and set:
NTMI.at(~uc4).influxMode;
NTMI.at(~uc4).setRel;

/* *****
*** We leave uc4 encoders on default absolute mode (0..127),
    and make them endless here:
- when we hit 0, go back up to 7 to allow next step down;
- when we hit 127, go back up to 120 to allow next step up;
****/

/// lower 4 knobs change slots volume
MKtl(~uc4).elAt(\vols).do { |el, i|
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

/// lower 4 buttons toggle sound slots on/off
MKtl(~uc4).elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.value > 0) { NTMI.slots.toggleAt(i) }
	};
};

// xfader is main volume before limiter
MKtl(~uc4).elAt('main').action = { |xf|
	// 	s.volume.volume_(\svol.asSpec.map(xf.value))
	MFdef(\mainVolSetUni).value(xf.value);
};

// normal: select next setting
// hat down: select next sound
// same
MKtl(~uc4).elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		var relStep = (el.deviceValue - el.prevDeviceValue).clip2(6);

		if (MKtl(~uc4).elAt(\selMode)[i].isOn) {
			// next sound
			NTMI.slots.stepNext(i, relStep);
		} {
			// next preset
			NTMI.pre.stepNdefInf(ndef, relStep);
		};
		// make encoder endless with small jump back:
		(    0: { defer ({ el.deviceValue_(7).trySend }, 0.03) },
			127: { defer ({ el.deviceValue_(120).trySend }, 0.03) }
		)[el.deviceValue].value;
	}
};



// bt5, snapshots presets of all currently playing sounds
MKtl(~uc4).elAt(\snap).action = { |el|
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
NTMI.at(~uc4).sliderOffset = NTMI.at(~uc4).sliderOffset ? 1;

MKtl(~uc4).elAt(\inflx).do { |sl, i|
	sl.action = { |sl|
		if (NTMI.at(~uc4).influxMode == \setAbs) {
			var name = NTMI.inphlux.inNames[i + NTMI.at(~uc4).sliderOffset];
			NTMI.inphlux.set(name, sl.value.unibi * NTMI.at(~uc4).zoom);
		} {
			MFdef(\setRelInf).(
				i + NTMI.inph.sliderOffset,
				(sl.prevValue - sl.value).clip2(0.05),
				NTMI.zoom * NTMI.at(~uc4).zoom
			)
		}
	}
};

// Left 3 bottom buttons: inphPre rand, -1, +1
MKtl(~uc4).elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
MKtl(~uc4).elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
MKtl(~uc4).elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };
MKtl(~uc4).elAt(\zero_inph).action = { |el| if (el.isOn) { NTMI.inphlux.resetInvals } };


// Right 3 bottom buttons: mainfx preset rand, -1, +1
MKtl(~uc4).elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
MKtl(~uc4).elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
MKtl(~uc4).elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

/**** add UC4 page2 - direct mode:
8 sliders on page2 PullSet set first 8 process params
hold down pgSl2 bt_1 to get params 9-16
************/

MKtl(~uc4).elAt('pgSl2', \sl).do { |sl, i|
	sl.action = { |sl|
		var index = MKtl(~uc4).elAt('pgSl2', \bt, 0).isOn.binaryValue * 8 + i;
		// [sl.name, sl.value.round(0.001)].postln;
		NTMI.slots.nowPlaying.do { |ndef|
			var paramKey = ndef.controlKeys[index];
			if (paramKey.notNil) {
				ndef.setUni(paramKey, sl.value);
			};
		};
	};
};

MKtl(~uc4);