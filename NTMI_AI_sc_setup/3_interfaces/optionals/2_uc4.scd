/******* UC4 setup for NTMI:

- top 4 knobs  		change slots volume / relative
- top 4 hat-buttons toggle sound slots on/off

- lower 4 knobs:
--					scroll thru presets
-- 					if hat held down, scroll thru sounds

- 8 sliders: 		influx!

- xfader:           mainVol via mainVol param

- bot buts 1 2 3:	rand, prev, next influx preset
- bot but  5:		snapshot presets
- bot buts 6 7 8:	rand, prev, next mainFX preset

- ( bot but  4 still unused ;-)


***********/
// to switch encoders to relative: on the device, select grp1,
// then go into edit mode: hold \shift, press \edit_setup
// select enc1 on knob 1, change ctlmode to Ccr2,
// hold until running bars go away -> all encoders are now relative

// MKtlDesc.loadDescs;
g.uc4.free; g.uc4 = MKtl(\uc4, "*uc4_pg");


// make all named elements first
g.uc4.addNamed(\main, g.uc4.elAt(\xfader));
g.uc4.addNamed(\inflx, g.uc4.elAt(\pgSl1, \sl));

// lower 4 encoders and their hatButtons for play and vol
g.uc4.addNamed(\vols, g.uc4.elAt(\pgKn1, \kn, (4..7)));
g.uc4.addNamed(\playBts, g.uc4.elAt(\pgKn1, \pbt, (4..7), 0));

// higher 4 encoders for changing presets, hold hats for processes
// select preset or sounds
g.uc4.addNamed(\select, g.uc4.elAt(\pgKn1, \kn, (0..3)));
// if but up, select preset, if down, sound
g.uc4.addNamed(\selMode, g.uc4.elAt(\pgKn1, \pbt, (0..3), 0));

g.uc4.addNamed(\rand_inph, g.uc4.elAt(\pgSl1, \bt, 0, 0));
g.uc4.addNamed(\prev_inph, g.uc4.elAt(\pgSl1, \bt, 1, 0));
g.uc4.addNamed(\next_inph, g.uc4.elAt(\pgSl1, \bt, 2, 0));
g.uc4.addNamed(\zero_inph, g.uc4.elAt(\pgSl1, \bt, 3, 0));

g.uc4.addNamed(\snap, g.uc4.elAt(\pgSl1, \bt, 4, 0));

g.uc4.addNamed(\rand_pre, g.uc4.elAt(\pgSl1, \bt, 5, 0));
g.uc4.addNamed(\prev_pre, g.uc4.elAt(\pgSl1, \bt, 6, 0));
g.uc4.addNamed(\next_pre, g.uc4.elAt(\pgSl1, \bt, 7, 0));


// modify labels, use only semantic element names:
g.uc4.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
g.uc4.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

g.uc4.elAt(\select).do { |el, i| el.elemDesc.label = "select".format(i+1) };
g.uc4.elAt(\selMode).do { |el, i| el.elemDesc.label = "^-pre v-snd".format(i+1) };

g.uc4.elAt(\inflx).do { |sl, i| sl.elemDesc.label = "inf" + q.inphlux.inNames[i].cs };

g.uc4.elAt(\main).elemDesc.label = "Main Vol";

g.uc4.elAt(\rand_inph).elemDesc.label = "rand inph";
g.uc4.elAt(\prev_inph).elemDesc.label = "prev inph";
g.uc4.elAt(\next_inph).elemDesc.label = "next inph";
g.uc4.elAt(\zero_inph).elemDesc.label = "zero inph";


g.uc4.elAt(\snap).elemDesc.label = "snap pre!";
g.uc4.elAt(\rand_pre).elemDesc.label = "rand MFX";
g.uc4.elAt(\prev_pre).elemDesc.label = "prev MFX";
g.uc4.elAt(\next_pre).elemDesc.label = "next MFX";


// init values
g.uc4.elAt('pgKn1', \kn).value = 0.5;
g.uc4.elAt('pgSl1', \sl).value = 0.5;
g.uc4.elAt('main').value = 0.5;


// g.makeGui.uc4 = { g.uc4.gui };

// add a spec to uc4, for relative use:
// ccr2 is from 58 ... 63 down / 65 .. 70 up,
// so use this for good resolution on gui elements

g.uc4.addSpec(\knRel, [56, 72, \lin, 1, 64]);
g.uc4.elAt(\pgKn1, \kn).do(_.deviceSpec_(g.uc4.getSpec(\knRel)));

/// top 4 knobs change slots volume
g.uc4.elAt(\vols).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		MFdef(\stepVol).(ndef, ((el.deviceValue - 64) * 0.4));
		el.deviceValue = 64;
	};
};

/// top 4 buttons toggle sound slots on/off

g.uc4.elAt(\playBts).do { |el, i|
	el.action = { |el|
		if (el.value > 0) { q.slots.toggleAt(i) }
	};
};

// xfader is main volume before limiter
g.uc4.elAt('main').action = { |xf|
	// 	s.volume.volume_(\svol.asSpec.map(xf.value))
	MFdef(\mainVol).value(xf.value);
};

// normal: select next setting
// hat down: select next sound
g.uc4.elAt(\select).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		var relStep = (el.deviceValue - 64);

		if (g.uc4.elAt(\selMode)[i].isOn) {
			// next sound
			q.slots.stepNext(i, relStep);
		} {
			// next preset
			q.pre.stepNdefInf(ndef, relStep);
		};
		el.deviceValue = 64;
	}
};

// bt5, snapshots presets of all currently playing sounds
g.uc4.elAt(\snap).action = { |el|
	if (el.isOn) {
		MFdef(\snapshot).value;
	}
};

// sliders set first 8 influx inputs
q.nktl.elAt(\inflSet).do { |sl, i|
	sl.action = { |sl|
		q.slots.nowPlaying.do { |ndef|
			q.inphlux.setRel(ndef, i, (sl.prevValue - sl.value), q.zoom);
		}
	}
};

// ////////// sliders (hard-)set or SoftSet inphlux:
// if (q.inphlux.respondsTo(\get).not) {
// 	"///////// sliders hard-set influx directly ".postln;
// 	g.uc4.elAt(\inflx).do { |sl, i|
// 		sl.action = { |sl|
// 			// make sure we get to amp control (inphlux.inNames[8])
// 			var name = q.inphlux.inNames[i + 1];
// 			q.inphlux.set(name, sl.value.unibi)
// 		};
// 	}
// } {
// 	///////// BETTER: SoftSet, works with current Influx update
// 	"//// sliders SoftSet influx ".postln;
// 	g.uc4.elAt(\inflx).do { |sl, i|
// 		sl.action = { |sl|
// 			// make sure we get to amp control (inphlux.inNames[8])
// 			var name = q.inphlux.inNames[i + 1];
// 			SoftSet(q.inphlux, name, sl.value.unibi, lastVal: sl.prevValue.unibi);
// 		};
// 	}
// };

"///////// sliders relative-set influx directly ".postln;
g.uc4.elAt(\inflx).do { |sl, i|
	sl.action = { |sl|
		q.slots.nowPlaying.do { |ndef|
			q.inphlux.setRel(ndef, i, (sl.prevValue - sl.value),
				q.zoom,
				ndef.controlKeys
			);
		}
	}
};



// Left 3 bottom buttons: inphPre rand, -1, +1
g.uc4.elAt(\rand_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).(nil) } };
g.uc4.elAt(\prev_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).(-1 ) } };
g.uc4.elAt(\next_inph).action = { |el| if (el.isOn) { MFdef(\stepInphWPre).( 1 ) } };
g.uc4.elAt(\zero_inph).action = { |el| if (el.isOn) { q.inphlux.resetInvals } };


// Right 3 bottom buttons: mainfx preset rand, -1, +1
g.uc4.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
g.uc4.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
g.uc4.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };



/**** add UC4 page2 - direct mode:
8 sliders on page2 PullSet set first 8 process params
hold down pgSl2 bt_1 to get params 9-16
************/

g.uc4.elAt('pgSl2', \sl).do { |sl, i|
	sl.action = { |sl|
		var index = g.uc4.elAt('pgSl2', \bt, 0).isOn.binaryValue * 8 + i;
		// [sl.name, sl.value.round(0.001)].postln;
		q.slots.nowPlaying.do { |ndef|
			var paramKey = ndef.controlKeys[index];
			if (paramKey.notNil) {
				ndef.setUni(paramKey, sl.value);
			};
		};
	};
};

g.uc4;