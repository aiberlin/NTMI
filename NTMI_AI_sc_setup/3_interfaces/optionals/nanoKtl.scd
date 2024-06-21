/******* make the same control interface for the NTMI app for two devices:

A nanoKontrol1 if present, or else a nanoKontrol2.

It does that by giving the elements custom access names first,
then given them the same actions, independently of which device they are on.
The same concept also works for gamepads and other devices.

-------- THE LAYOUT: ----------
- left knobs 1-4  		change slots volume (with softVol takeover)
- bottom buttons 1-4 	toggle sound slots on/off

- knobs 5-8 		select presets or sounds
-- button 5-8 up	scroll thru presets
-- button 5-8 down	scroll thru sounds

- sliders 1-8/1-7: 	influx!

- last slider 8/9:	mainVol via mainVol

transport buttons:
nk1: rew, play, fwd:	rand, prev, next influx preset
nk2: cycle, rew, fwd 	rand, prev, next influx preset

nk1: loop, stop, rec:  rand, prev, next MainFX preset
nk2: stop, play, rec:  rand, prev, next MainFX preset

- top row(s) of buttons still unused.

***********/


if (MKtlLookup.findByIDInfo("nanoKONTROL").size > 0) {
	MKtl.all.nanoKtl.free;
	MKtl('nanoKtl', "korg-nanokontrol");

	// make all named elements first
	MKtl(\nanoKtl).addNamed(\main, MKtl(\nanoKtl).elAt(\sl, 0, 8));
	MKtl(\nanoKtl).addNamed(\inflx, MKtl(\nanoKtl).elAt(\sl, 0, (0..7)));

	MKtl(\nanoKtl).addNamed(\vols, MKtl(\nanoKtl).elAt(\kn, 0, (0..3)));
	MKtl(\nanoKtl).addNamed(\playBts, MKtl(\nanoKtl).elAt(\bt, 0, 1, (0..3)));

	// select preset or sounds
	MKtl(\nanoKtl).addNamed(\select, MKtl(\nanoKtl).elAt(\kn, 0, (4..7)));
	// if but up, select preset, if down, sound
	MKtl(\nanoKtl).addNamed(\selMode, MKtl(\nanoKtl).elAt(\bt, 0, 1, (4..7)));

	MKtl(\nanoKtl).addNamed(\rand_inph, MKtl(\nanoKtl).elAt(\tr, \rew));
	MKtl(\nanoKtl).addNamed(\prev_inph, MKtl(\nanoKtl).elAt(\tr, \play));
	MKtl(\nanoKtl).addNamed(\next_inph, MKtl(\nanoKtl).elAt(\tr, \fwd));

	MKtl(\nanoKtl).addNamed(\rand_pre, MKtl(\nanoKtl).elAt(\tr, \loop));
	MKtl(\nanoKtl).addNamed(\prev_pre, MKtl(\nanoKtl).elAt(\tr, \stop));
	MKtl(\nanoKtl).addNamed(\next_pre, MKtl(\nanoKtl).elAt(\tr, \rec));


} {
	// assume nanoKONTROL2:
	// MKtl(\nanoKtl).desc.fullDesc.idInfo.cs
	// if (MKtlLookup.findByIDInfo("nanoKONTROL2").size > 0) {
	MKtl.all.nanoKtl.free;
	MKtl('nanoKtl', "korg-nanokontrol2");

	// make all named elements first
	MKtl(\nanoKtl).addNamed(\main, MKtl(\nanoKtl).elAt(\sl, 7));
	MKtl(\nanoKtl).addNamed(\inflSet, MKtl(\nanoKtl).elAt(\sl, (0..6)));

	MKtl(\nanoKtl).addNamed(\vols, MKtl(\nanoKtl).elAt(\kn, (0..3)));
	MKtl(\nanoKtl).addNamed(\playBts, MKtl(\nanoKtl).elAt(\bt, 2, (0..3)));

	// select preset or sounds
	MKtl(\nanoKtl).addNamed(\select, MKtl(\nanoKtl).elAt(\kn, (4..7)));
	// if but up, select preset, if down, sound
	MKtl(\nanoKtl).addNamed(\selMode, MKtl(\nanoKtl).elAt(\bt, 2, (4..7)));

	MKtl(\nanoKtl).addNamed(\rand_inph, MKtl(\nanoKtl).elAt(\tr, \cycle));
	MKtl(\nanoKtl).addNamed(\prev_inph, MKtl(\nanoKtl).elAt(\tr, \rew));
	MKtl(\nanoKtl).addNamed(\next_inph, MKtl(\nanoKtl).elAt(\tr, \fwd));

	MKtl(\nanoKtl).addNamed(\prev_pre, MKtl(\nanoKtl).elAt(\tr, \stop));
	MKtl(\nanoKtl).addNamed(\rand_pre, MKtl(\nanoKtl).elAt(\tr, \play));
	MKtl(\nanoKtl).addNamed(\next_pre, MKtl(\nanoKtl).elAt(\tr, \rec));

};

// *** add local settings and functions to nanoKtl ***
// local zoom value:
MKtl(\nanoKtl).addSpec(\zoom, [0, 4, \amp]);
MKtl(\nanoKtl).addHalo(\zoom, 1);

// allow direct access of halo via NTMI:
NTMI.nanoKtl = MKtl(\nanoKtl).getHalo;
// and access like this
NTMI.nanoKtl.zoom.postln;

// flag whether to use influx in relative or absolute mode:
// (there could be more modes, e.g. softAbs ...)
NTMI.nanoKtl.influxMode = \setRel;

// set functions for the two supported modes:
NTMI.nanoKtl.setRel = {
	MKtl(\nanoKtl).getHalo.influxMode = \setRel;
	"nanoKtl influxMode is now: %\n.".postf(\setRel);
};
NTMI.nanoKtl.setAbs = {
	MKtl(\nanoKtl).getHalo.influxMode = \setAbs;
	"nanoKtl influxMode is now: %\n.".postf(\setAbs);
};
// read and set:
NTMI.nanoKtl.influxMode;
NTMI.nanoKtl.setRel;


MKtl(\nanoKtl).elAt(\inflSet).do(_.value = 0.5);


MKtl(\nanoKtl).elAt(\main).elemDesc.label = "Main Vol";

MKtl(\nanoKtl).elAt(\rand_inph).elemDesc.label = "rand inph";
MKtl(\nanoKtl).elAt(\prev_inph).elemDesc.label = "prev inph";
MKtl(\nanoKtl).elAt(\next_inph).elemDesc.label = "next inph";

MKtl(\nanoKtl).elAt(\rand_pre).elemDesc.label = "rand MFX";
MKtl(\nanoKtl).elAt(\prev_pre).elemDesc.label = "prev MFX";
MKtl(\nanoKtl).elAt(\next_pre).elemDesc.label = "next MFX";

// modify labels:
MKtl(\nanoKtl).elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
MKtl(\nanoKtl).elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

MKtl(\nanoKtl).elAt(\selMode).do { |el, i| el.elemDesc.label = "mod sl%".format(i+1) };
MKtl(\nanoKtl).elAt(\select).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

MKtl(\nanoKtl).elAt(\inflSet).do { |sl, i| sl.elemDesc.label = "inf" + NTMI.inphlux.inNames[i].cs };


/// left top 4 knobs change slots volume
MKtl(\nanoKtl).elAt(\vols).do { |el, i|
	el.action = { |el|
		NTMI.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
	};
};

// left bottom 4 buttons toggle sound slots on/off
MKtl(\nanoKtl).elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.isOn) { NTMI.slots.toggleAt(i) }
	};
};

MKtl(\nanoKtl).elAt(\inflSet).do { |sl, i|
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
MKtl(\nanoKtl).elAt(\main).action = { |sl|
	MFdef(\mainVolSetUni).value(sl.value) };
MKtl(\nanoKtl).elAt(\main).value = 0.5;

// normal: select next setting
// hat down: select next sound
MKtl(\nanoKtl).elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		if (MKtl(\nanoKtl).elAt(\selMode)[i].isOn) {
			// next sound
			NTMI.slots.stepNext(i, relStep);
		} {
			// next preset
			NTMI.pre.stepNdefInf(ndef, relStep);
		};
	};
};

MKtl(\nanoKtl).elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
MKtl(\nanoKtl).elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
MKtl(\nanoKtl).elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };

MKtl(\nanoKtl).elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
MKtl(\nanoKtl).elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
MKtl(\nanoKtl).elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

// snapshot
MKtl(\nanoKtl).elAt(\tr, 'mset').elemDesc.label = "snap pre!";
MKtl(\nanoKtl).elAt(\tr, 'mset').action = { |el| if (el.isOn, MFdef(\snapshot)) };

MKtl(\nanoKtl);