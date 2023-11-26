/******* make a control interface for the NTMI app for the behringer xtouch


-------- THE LAYOUT: ----------

main volume : big slider
play/stop slot: buttons A 1-4

set relative influx: 8 knobs

set volume per slot: hold MC button, knob 5-8
set preset per slot: hold MC button, knob 1-4
set sound per slot : hold MC + press hat knob  1-4


record button -> snapshot

hold MC button and turn
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

MKtlDesc.openFolder

q = q ? ();
q.xt = (knobMode: \infl);

q.xtm.gui.showLabels;

if (MKtlLookup.findByIDInfo("X-TOUCH MINI").size > 0) {

	q.xtm.free;
	q.xtm = MKtl('xtm', "*x-touch-mini*");

	// main volume
	q.xtm.addNamed(\main, q.xtm.elAt(\A, \sl));
	q.xtm.elAt(\main).elemDesc.label = "Main Vol";
	q.xtm.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };

	// play buttons for the four slots
	q.xtm.addNamed(\playBts, q.xtm.elAt(\A, \chan, (0..3), \bt, \A, 0));
	q.xtm.elAt(\playBts).do { |el, i| el.elemDesc.label = "play" + (i + 1) };
	q.xtm.elAt(\playBts).do { |el, i|
		el.action = { q.slots.toggleAt(i) };
	};

	// we want to use the encoders for several things:
	// setting volume per slot, and playing influx inputs.
	// so, we need ways to switch modes...

	// first, we make the named elements - encoders, hats, MC button
	q.xtm.addNamed(\enc, q.xtm.elAt(\A, \chan, nil, \enc, 0));
	q.xtm.addNamed(\enchat, q.xtm.elAt(\A, \chan, nil, \enc, 1));
	// define MC button to use for mode switching
	q.xtm.addNamed(\MC, q.xtm.elAt(\A, \chan, 0, \bt, \B, 0));

	// first pass: use encoders to do absolute influx setting
	q.xtm.elAt(\enc).do { |enc, i|
		enc.action = { |enc|
			var name = q.inphlux.inNames[i + q.inph.sliderOffset ? 1];
			q.inphlux.set(name, enc.value.unibi);
		};
	};

	// try new relative set for 8 sliders
	// this means the knobs never jump
	q.xtm.elAt(\enc).do { |enc, i|
		enc.action = { |enc|
			q.slots.nowPlaying.do { |ndef|
				// add sliderOffset + 1, so we get to channel 8 for amp tweak
				q.inphlux.setRel(ndef, i + q.inph.sliderOffset ? 1 + 1,
					(enc.prevValue - enc.value),
					q.zoom,
					ndef.controlKeys
				);
			}
		}
	};

	// volume per slot: press encoder and turn
	q.xtm.elAt(\enc).do { |el, i|
		// first 4 change volume
		if (i < 4) {
			el.action = { |enc|
				"volume".postln;
				q.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
			};
		} {
			// second 4 should step thru NdefPreset setting
			el.action = { |enc|
				var step = enc.deviceValue - enc.prevDeviceValue;
				var ndef = q.ndefs[i-4];
				q.pre.stepNdefInf( ndef, step );
			};
		};
	};

	// TODO: add mode where to select sounds
	// step thru / jump influx presets
	// step thru / rand mainfx presets


	// // select preset or sounds
	// q.xtm.addNamed(\select, q.xtm.elAt(\kn, 0, (4..7)));
	// // if but up, select preset, if down, sound
	// q.xtm.addNamed(\selMode, q.xtm.elAt(\bt, 0, 1, (4..7)));
	//
	// q.xtm.addNamed(\rand_inph, q.xtm.elAt(\tr, \rew));
	// q.xtm.addNamed(\prev_inph, q.xtm.elAt(\tr, \play));
	// q.xtm.addNamed(\next_inph, q.xtm.elAt(\tr, \fwd));
	//
	// q.xtm.addNamed(\rand_pre, q.xtm.elAt(\tr, \loop));
	// q.xtm.addNamed(\prev_pre, q.xtm.elAt(\tr, \stop));
	// q.xtm.addNamed(\next_pre, q.xtm.elAt(\tr, \rec));



	// q.xtm.elAt(\rand_inph).elemDesc.label = "rand inph";
	// q.xtm.elAt(\prev_inph).elemDesc.label = "prev inph";
	// q.xtm.elAt(\next_inph).elemDesc.label = "next inph";
	//
	// q.xtm.elAt(\rand_pre).elemDesc.label = "rand MFX";
	// q.xtm.elAt(\prev_pre).elemDesc.label = "prev MFX";
	// q.xtm.elAt(\next_pre).elemDesc.label = "next MFX";

	// modify labels:
	q.xtm.elAt(\vols).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
	q.xtm.elAt(\playBts).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

	q.xtm.elAt(\selMode).do { |el, i| el.elemDesc.label = "mod sl%".format(i+1) };
	q.xtm.elAt(\select).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

	q.xtm.elAt(\inflSet).do { |sl, i| sl.elemDesc.label = "inf" + q.inphlux.inNames[i].cs };


	/// left top 4 knobs change slots volume
	q.xtm.elAt(\vols).do { |el, i|
		el.action = { |el|
			q.ndefs[i].softVol_(el.value, lastVal: el.prevValue);
		};
	};

	// left bottom 4 buttons toggle sound slots on/off
	q.xtm.elAt(\playBts).do { |el, i|
		el.action = { |el|
			if (el.isOn) { q.slots.toggleAt(i) }
		};
	};

	// // sliders set influx inputs - absolute:
	// q.xtm.elAt(\inflSet).do { |sl, i|
	// 	sl.action = { |sl|
	// 		var name = q.inphlux.inNames[i];
	// 		q.inphlux.set(name, sl.value.unibi);
	// 	}
	// };

	// new relative set for 7 sliders
	q.xtm.elAt(\inflSet).do { |sl, i|
		sl.action = { |sl|
			q.slots.nowPlaying.do { |ndef|
				// add sliderOffset + 1, so we get to channel 8 for amp tweak
				q.inphlux.setRel(ndef, i + q.inph.sliderOffset ? 1 + 1,
					(sl.prevValue - sl.value),
					q.zoom,
					ndef.controlKeys
				);
			}
		}
	};

	// rightmost slider is main volume (into limiter)
	q.xtm.elAt(\main).action = { |sl| MFdef(\mainVol).value(sl.value) };
	q.xtm.elAt(\main).value = 0.5;

	// normal: select next setting
	// hat down: select next sound
	q.xtm.elAt(\select).do { |el, i|
		el.action = { |el|
			var ndef = q.ndefs[i];
			var relStep = (el.deviceValue - el.prevValue).sign;
			if (q.xtm.elAt(\selMode)[i].isOn) {
				// next sound
				q.slots.stepNext(i, relStep);
			} {
				// next preset
				q.pre.stepNdefInf(ndef, relStep);
			};
		};
	};

	q.xtm.elAt(\rand_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(nil) } };
	q.xtm.elAt(\prev_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre(-1 ) } };
	q.xtm.elAt(\next_inph).action = { |el| if (el.isOn) { NTMI.inph.stepWPre( 1 ) } };

	q.xtm.elAt(\rand_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(nil) } };
	q.xtm.elAt(\prev_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).(-1 ) } };
	q.xtm.elAt(\next_pre).action = { |el| if (el.isOn) { MFdef(\mainPreStep).( 1 ) } };

	// snapshot
	q.xtm.elAt(\tr, 'mset').elemDesc.label = "snap pre!";
	q.xtm.elAt(\tr, 'mset').action = { |el| if (el.isOn, MFdef(\snapshot)) };

	q.xtm;