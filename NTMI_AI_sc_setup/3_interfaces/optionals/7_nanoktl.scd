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
q.nk = ();

if (MKtlLookup.findByIDInfo("nanoKONTROL").size > 0) {
	q.nktl.free;
	q.nktl = MKtl('nk1', "korg-nanokontrol");

	// make all named elements first
	q.nktl.addNamed(\main, q.nktl.elAt(\sl, 0, 8));
	q.nktl.addNamed(\inflx, q.nktl.elAt(\sl, 0, (0..7)));

	q.nktl.addNamed(\vols, q.nktl.elAt(\kn, 0, (0..3)));
	q.nktl.addNamed(\playBts, q.nktl.elAt(\bt, 0, 1, (0..3)));

	// select preset or sounds
	q.nktl.addNamed(\select, q.nktl.elAt(\kn, 0, (4..7)));
	// if but up, select preset, if down, sound
	q.nktl.addNamed(\selMode, q.nktl.elAt(\bt, 0, 1, (4..7)));

	q.nktl.addNamed(\rand_inph, q.nktl.elAt(\tr, \rew));
	q.nktl.addNamed(\prev_inph, q.nktl.elAt(\tr, \play));
	q.nktl.addNamed(\next_inph, q.nktl.elAt(\tr, \fwd));

	q.nktl.addNamed(\rand_pre, q.nktl.elAt(\tr, \loop));
	q.nktl.addNamed(\prev_pre, q.nktl.elAt(\tr, \stop));
	q.nktl.addNamed(\next_pre, q.nktl.elAt(\tr, \rec));


} {
	// if (MKtlLookup.findByIDInfo("Run'N' Drive Wireless_Thrustmaster").size > 0) {
	q.nktl.free;
	q.nktl = MKtl('nanoKtl', "korg-nanokontrol2");

	// make all named elements first
	q.nktl.addNamed(\main, q.nktl.elAt(\sl, 7));
	q.nktl.addNamed(\inflSet, q.nktl.elAt(\sl, (0..6)));

	q.nktl.addNamed(\vols, q.nktl.elAt(\kn, (0..3)));
	q.nktl.addNamed(\playBts, q.nktl.elAt(\bt, 2, (0..3)));

	// select preset or sounds
	q.nktl.addNamed(\select, q.nktl.elAt(\kn, (4..7)));
	// if but up, select preset, if down, sound
	q.nktl.addNamed(\selMode, q.nktl.elAt(\bt, 2, (4..7)));

	q.nktl.addNamed(\rand_inph, q.nktl.elAt(\tr, \cycle));
	q.nktl.addNamed(\prev_inph, q.nktl.elAt(\tr, \rew));
	q.nktl.addNamed(\next_inph, q.nktl.elAt(\tr, \fwd));

	q.nktl.addNamed(\rand_pre, q.nktl.elAt(\tr, \stop));
	q.nktl.addNamed(\prev_pre, q.nktl.elAt(\tr, \play));
	q.nktl.addNamed(\next_pre, q.nktl.elAt(\tr, \rec));

	// };
};

q.nktl.elAt(\inflSet).do(_.value = 0.5);


q.nktl.elAt(\main).elemDesc.label = "Main Vol";

q.nktl.elAt(\rand_inph).elemDesc.label = "rand inph";
q.nktl.elAt(\prev_inph).elemDesc.label = "prev inph";
q.nktl.elAt(\next_inph).elemDesc.label = "next inph";

q.nktl.elAt(\rand_pre).elemDesc.label = "rand MFX";
q.nktl.elAt(\prev_pre).elemDesc.label = "prev MFX";
q.nktl.elAt(\next_pre).elemDesc.label = "next MFX";

// modify labels:
q.nktl.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
q.nktl.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

q.nktl.elAt(\selMode).do { |el, i| el.elemDesc.label = "mod sl%".format(i+1) };
q.nktl.elAt(\select).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

q.nktl.elAt(\inflSet).do { |sl, i| sl.elemDesc.label = "inf" + q.inphlux.inNames[i].cs };


/// left top 4 knobs change slots volume
q.nktl.elAt(\vols).do { |el, i|
	el.action = { |el|
		q.ndefs[i].softVol_(el.value.postln, lastVal: el.prevValue);
	};
};

// left bottom 4 buttons toggle sound slots on/off
q.nktl.elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.isOn) { q.slots.toggleAt(i) }
	};
};

// // sliders set influx inputs
// q.nktl.elAt(\inflSet).do { |sl, i|
// 	sl.action = { |sl|
// 		var name = q.inphlux.inNames[i];
// 		q.inphlux.set(name, sl.value.unibi);
// 	}
// };

// new relative set for 7 sliders
q.nktl.elAt(\inflSet).do { |sl, i|
	sl.action = { |sl|
		q.slots.nowPlaying.do { |ndef|
			q.inphlux.setRel(ndef, i, (sl.prevValue - sl.value),
				q.zoom,
				ndef.controlKeys
			);
		}
	}
};

// rightmost slider is main volume (into limiter)
q.nktl.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };
q.nktl.elAt(\main).value = 0.5;

// rightmost slider is main volume (into limiter)
q.nktl.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };
q.nktl.elAt(\main).value = 0.5;

// normal: select next setting
// hat down: select next sound
q.nktl.elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		if (q.nktl.elAt(\selMode)[i].isOn) {
			// next sound
			q.slots.stepNext(i, relStep);
		} {
			// next preset
			q.pre.stepNdefInf(ndef, relStep);
		};
	};
};

q.nktl.elAt(\rand_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).(nil) } };
q.nktl.elAt(\prev_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).(-1 ) } };
q.nktl.elAt(\next_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).( 1 ) } };

q.nktl.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
q.nktl.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
q.nktl.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

// snapshot
q.nktl.elAt(\tr, 'mset').elemDesc.label = "snap pre!";
q.nktl.elAt(\tr, 'mset').action = { |el| if (el.isOn, MFdef(\snapshot)) };

q.nktl;