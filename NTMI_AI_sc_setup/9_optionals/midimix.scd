/******* make control interface for the NTMI app for the:

******* AKAI MIDIMIX **********

Specific elements are given:
1 - custom access names,
2 - custom labels that show on the gui,
3 - actions that remain the same across all control devices.

-------- THE LAYOUT: ----------
- left knobs top 1-4  	change slots volume (with softVol takeover)
- left knobs mid 1-4  	scroll thru sound presets
- left knobs bottom 1-4 scroll thru sound functions

- bottom buttons 1-4 	toggle sound slots on/off

- right side buttons	rand, prev, next influx preset

- right buts 1, 5-8: 	rand, prev, next masterFX

- sliders 1-8/0-7: 	influx!

- last slider 8/9:	mainVol via mainVol
***********/

(
q = q ? ();

// if (MKtlLookup.findByIDInfo("MIDI Mix").size > 0) { };
q.mmx.free;
q.mmx = MKtl(\mmx, "akai-midimix");

// make all named elements first
q.mmx.addNamed(\main, q.mmx.elAt(\sl, 8));
q.mmx.addNamed(\inflSet, q.mmx.elAt(\sl, (0..7)));

q.mmx.addNamed(\vols, q.mmx.elAt(\kn, \1, (0..3)));
q.mmx.addNamed(\playBts, q.mmx.elAt(\bt, \1, (0..3)));

// ///////// orig
// // select preset or sounds
// q.mmx.addNamed(\select, q.mmx.elAt(\kn, \1, (4..7)));
// // if but up, select preset, if down, sound
// q.mmx.addNamed(\selMode, q.mmx.elAt(\bt, \1, (4..7)));

// ///////// adc proposal to select preset or sounds:
/////// use kn, 2, 1-4 for preset select,
/////// kn 3 1-4 for sound select, then we need no modebutton!

q.mmx.addNamed(\selPre, q.mmx.elAt(\kn, \2, (0..3)));
q.mmx.addNamed(\selSnd, q.mmx.elAt(\kn, \3, (0..3)));

/// buttons - inphlux presets on the right
// only use the on buttons
q.mmx.addNamed(\rand_inph, q.mmx.elAt(\solo, \on));
q.mmx.addNamed(\prev_inph, q.mmx.elAt(\bankLeft, \on));
q.mmx.addNamed(\next_inph, q.mmx.elAt(\bankRight, \on));

// master fx on right 3 rows
q.mmx.addNamed(\rand_pre, q.mmx.elAt(\bt, \1, 5, \on));
q.mmx.addNamed(\prev_pre, q.mmx.elAt(\bt, \1, 6, \on));
q.mmx.addNamed(\next_pre, q.mmx.elAt(\bt, \1, 7, \on));


/////////// modify the labels shown on gui:
// single elements
q.mmx.elAt(\main).elemDesc.label = "Main Vol";

q.mmx.elAt(\rand_inph).elemDesc.label = "rand inph";
q.mmx.elAt(\prev_inph).elemDesc.label = "prev inph";
q.mmx.elAt(\next_inph).elemDesc.label = "next inph";

q.mmx.elAt(\rand_pre).elemDesc.label = "rand MFX";
q.mmx.elAt(\prev_pre).elemDesc.label = "prev MFX";
q.mmx.elAt(\next_pre).elemDesc.label = "next MFX";

// groups of elements
q.mmx.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
q.mmx.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

q.mmx.elAt(\kn).value = 0.5;
q.mmx.elAt(\sl).value = 0.5;

q.mmx.elAt(\selPre).do { |el, i| el.elemDesc.label = "slc% pre".format(i+1) };
q.mmx.elAt(\selSnd).do { |el, i| el.elemDesc.label = "slc% snd".format(i+1) };

q.mmx.elAt(\inflSet).do { |sl, i|
	sl.elemDesc.label = "inf" + q.inphlux.inNames[i].cs;
	sl.value = 0.5;
};


/// left top 4 knobs change slots volume
q.mmx.elAt(\vols).do { |el, i|
	el.action = { |el|
		q.ndefs[i].softVol_(el.value.squared, lastVal: el.prevValue.squared);
	};
};

// left bottom 4 buttons toggle sound slots on/off
q.mmx.elAt(\playBts).do { |el, i|
	el.action = { |el|
		el.name.postln;
		if (el.keyInGroup == \on) { q.slots.playAt(i) } { q.slots.stopAt(i) };
	};
};

// sliders set influx inputs
q.mmx.elAt(\inflSet).do { |sl, i|
	sl.action = { |sl|
		var name = q.inphlux.inNames[i];
		q.inphlux.set(name, sl.value.unibi);
	}
};

// rightmost slider is main volume (into limiter)
q.mmx.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };


// select next sound preset setting

q.mmx.elAt(\selPre).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		// next preset
		q.pre.stepNdefInf(ndef, relStep);
	}
};
// select next sound function
q.mmx.elAt(\selSnd).do { |el, i|
	el.action = { |el|
		var relStep = (el.deviceValue - el.prevValue).sign;
		q.slots.stepNext(i, relStep);
	}
};

q.mmx.elAt(\rand_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).(nil) } };
q.mmx.elAt(\prev_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).(-1 ) } };
q.mmx.elAt(\next_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).( 1 ) } };

q.mmx.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mastaPreStep).(nil) } };
q.mmx.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mastaPreStep).(-1 ) } };
q.mmx.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mastaPreStep).( 1 ) } };

g.makeGui;
)
