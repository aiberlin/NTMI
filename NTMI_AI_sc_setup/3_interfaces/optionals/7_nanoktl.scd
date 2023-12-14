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


q = q ? ();
NTMI.nk = ();

if (MKtlLookup.findByIDInfo("nanoKONTROL").size > 0) {
	NTMI.nktl.free;
	NTMI.nktl = MKtl('nk1', "korg-nanokontrol");

	// make all named elements first
	NTMI.nktl.addNamed(\main, NTMI.nktl.elAt(\sl, 0, 8));
	NTMI.nktl.addNamed(\inflx, NTMI.nktl.elAt(\sl, 0, (0..7)));

	NTMI.nktl.addNamed(\vols, NTMI.nktl.elAt(\kn, 0, (0..3)));
	NTMI.nktl.addNamed(\playBts, NTMI.nktl.elAt(\bt, 0, 1, (0..3)));

	// select preset or sounds
	NTMI.nktl.addNamed(\select, NTMI.nktl.elAt(\kn, 0, (4..7)));
	// if but up, select preset, if down, sound
	NTMI.nktl.addNamed(\selMode, NTMI.nktl.elAt(\bt, 0, 1, (4..7)));

	NTMI.nktl.addNamed(\rand_inph, NTMI.nktl.elAt(\tr, \rew));
	NTMI.nktl.addNamed(\prev_inph, NTMI.nktl.elAt(\tr, \play));
	NTMI.nktl.addNamed(\next_inph, NTMI.nktl.elAt(\tr, \fwd));

	NTMI.nktl.addNamed(\rand_pre, NTMI.nktl.elAt(\tr, \loop));
	NTMI.nktl.addNamed(\prev_pre, NTMI.nktl.elAt(\tr, \stop));
	NTMI.nktl.addNamed(\next_pre, NTMI.nktl.elAt(\tr, \rec));


} {
	// if (MKtlLookup.findByIDInfo("Run'N' Drive Wireless_Thrustmaster").size > 0) {
	NTMI.nktl.free;
	NTMI.nktl = MKtl('nanoKtl', "korg-nanokontrol2");

	// make all named elements first
	NTMI.nktl.addNamed(\main, NTMI.nktl.elAt(\sl, 7));
	NTMI.nktl.addNamed(\inflSet, NTMI.nktl.elAt(\sl, (0..6)));

	NTMI.nktl.addNamed(\vols, NTMI.nktl.elAt(\kn, (0..3)));
	NTMI.nktl.addNamed(\playBts, NTMI.nktl.elAt(\bt, 2, (0..3)));

	// select preset or sounds
	NTMI.nktl.addNamed(\select, NTMI.nktl.elAt(\kn, (4..7)));
	// if but up, select preset, if down, sound
	NTMI.nktl.addNamed(\selMode, NTMI.nktl.elAt(\bt, 2, (4..7)));

	NTMI.nktl.addNamed(\rand_inph, NTMI.nktl.elAt(\tr, \cycle));
	NTMI.nktl.addNamed(\prev_inph, NTMI.nktl.elAt(\tr, \rew));
	NTMI.nktl.addNamed(\next_inph, NTMI.nktl.elAt(\tr, \fwd));

	NTMI.nktl.addNamed(\rand_pre, NTMI.nktl.elAt(\tr, \stop));
	NTMI.nktl.addNamed(\prev_pre, NTMI.nktl.elAt(\tr, \play));
	NTMI.nktl.addNamed(\next_pre, NTMI.nktl.elAt(\tr, \rec));

	// };
};

NTMI.nktl.elAt(\inflSet).do(_.value = 0.5);


NTMI.nktl.elAt(\main).elemDesc.label = "Main Vol";

NTMI.nktl.elAt(\rand_inph).elemDesc.label = "rand inph";
NTMI.nktl.elAt(\prev_inph).elemDesc.label = "prev inph";
NTMI.nktl.elAt(\next_inph).elemDesc.label = "next inph";

NTMI.nktl.elAt(\rand_pre).elemDesc.label = "rand MFX";
NTMI.nktl.elAt(\prev_pre).elemDesc.label = "prev MFX";
NTMI.nktl.elAt(\next_pre).elemDesc.label = "next MFX";

// modify labels:
NTMI.nktl.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
NTMI.nktl.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

NTMI.nktl.elAt(\selMode).do { |el, i| el.elemDesc.label = "mod sl%".format(i+1) };
NTMI.nktl.elAt(\select).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

NTMI.nktl.elAt(\inflSet).do { |sl, i| sl.elemDesc.label = "inf" + NTMI.inphlux.inNames[i].cs };


/// left top 4 knobs change slots volume
NTMI.nktl.elAt(\vols).do { |el, i|
	el.action = { |el|
		NTMI.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
	};
};

// left bottom 4 buttons toggle sound slots on/off
NTMI.nktl.elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.isOn) { NTMI.slots.toggleAt(i) }
	};
};

// // sliders set influx inputs - absolute:
// NTMI.nktl.elAt(\inflSet).do { |sl, i|
// 	sl.action = { |sl|
// 		var name = NTMI.inphlux.inNames[i];
// 		NTMI.inphlux.set(name, sl.value.unibi);
// 	}
// };

// new relative set for 7 sliders
"//// nanoKontrol - relative-set \n"
"//// influx inputs %..% \n\n".postf(*NTMI.inph.sliderOffset + 1 + [0, NTMI.nktl.elAt(\inflSet).size]);

NTMI.zooms.nktl = 1;

NTMI.nktl.elAt(\inflSet).do { |sl, i|
	sl.action = { |sl|
		NTMI.slots.nowPlaying.do { |ndef|
			// add sliderOffset + 1, so we get to channel 8 for amp tweak
			MFdef(\setRelInf).(
				NTMI.inph.sliderOffset + 1 + i,
				(sl.prevValue - sl.value),
				NTMI.zoom * NTMI.zooms.nktl
			)
		}
	}
};

// rightmost slider is main volume (into limiter)
NTMI.nktl.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };
NTMI.nktl.elAt(\main).value = 0.5;

// rightmost slider is main volume (into limiter)
NTMI.nktl.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };
NTMI.nktl.elAt(\main).value = 0.5;

// normal: select next setting
// hat down: select next sound
NTMI.nktl.elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = NTMI.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		if (NTMI.nktl.elAt(\selMode)[i].isOn) {
			// next sound
			NTMI.slots.stepNext(i, relStep);
		} {
			// next preset
			NTMI.pre.stepNdefInf(ndef, relStep);
		};
	};
};

NTMI.nktl.elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
NTMI.nktl.elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
NTMI.nktl.elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };

NTMI.nktl.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
NTMI.nktl.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
NTMI.nktl.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

// snapshot
NTMI.nktl.elAt(\tr, 'mset').elemDesc.label = "snap pre!";
NTMI.nktl.elAt(\tr, 'mset').action = { |el| if (el.isOn, MFdef(\snapshot)) };

NTMI.nktl;