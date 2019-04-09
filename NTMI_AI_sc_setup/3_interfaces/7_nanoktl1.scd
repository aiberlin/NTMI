/******* nanoKontrol 1 setup for NTMI, page 1

- left knobs 1-4  		change slots volume (with softVol takeover)
- bottom buttons 1-4 	toggle sound slots on/off

- knobs 5-8 		select presets or sounds
-- button 5-8 up	scroll thru presets
-- button 5-8 down	scroll thru sounds

- sliders 1-8: 		influx!

- last slider 9:	masterVol via limDrive

transport buttons:
- rew, play, fwd:	rand, prev, next influx preset
- loop, stop, rec:  rand, prev, next MasterFX preset
- bot buts 6 7 8:

- top row of buttons still unused.

***********/

*/

q = q ? ();
q.nk = ();

q.nktl.free;
q.nktl = MKtl('nanoKtl', "korg-nanokontrol");


// modify labels:
q.nktl.elAt(\kn, 0, (0..3)).do { |el, i| el.elemDesc.label = "snd % vol".format(i+1) };
q.nktl.elAt(\bt, 0, 1, (0..3)).do { |el, i| el.elemDesc.label = "snd % play".format(i+1) };

q.nktl.elAt(\kn, 0, (4..7)).do { |el, i| el.elemDesc.label = "slct %".format(i+1) };
// q.nktl.elAt(\bt, 0, 0, (4..7)).do { |el, i| el.elemDesc.label = "slc % pre".format(i+1) };
q.nktl.elAt(\bt, 0, 1, (4..7)).do { |el, i| el.elemDesc.label = "slc % snd".format(i+1) };

q.nktl.elAt(\sl, 0, (0..7)).do { |sl, i| sl.elemDesc.label = "inf" + q.inphlux.inNames[i].cs };

q.nktl.elAt(\sl, 0, 8).elemDesc.label = "Main Vol";

q.nktl.elAt(\tr, \rew).elemDesc.label = "rand inph";
q.nktl.elAt(\tr, \play).elemDesc.label = "prev inph";
q.nktl.elAt(\tr, \fwd).elemDesc.label = "next inph";

q.nktl.elAt(\tr, \loop).elemDesc.label = "rand MFX";
q.nktl.elAt(\tr, \stop).elemDesc.label = "prev MFX";
q.nktl.elAt(\tr, \rec).elemDesc.label = "next MFX";


/// left top 4 knobs change slots volume
q.nktl.elAt(\kn, 0, (0..3)).do { |el, i|
	el.action = { |el|
		q.ndefs[i].softVol_(el.value.postln, lastVal: el.prevValue);
	};
};

// left bottom 4 buttons toggle sound slots on/off
q.nktl.elAt(\bt, 0, 1, (0..3)).do { |el, i|
	el.action = { |el|
		if (el.isOn) { q.slots.toggleAt(i) }
	};
};

// sliders set influx inputs
q.nktl.elAt(\sl, 0, (0..7)).do { |sl, i|
	sl.action = { |sl|
		var name = q.inphlux.inNames[i];
		q.inphlux.set(name, sl.value.unibi);
	}
};

// rightmost slider is master volume (into limiter)
q.nktl.elAt(\sl, 0, 8).action = { |sl|
	q.mFX.pxChain.proxy.setUni(\limDrive, sl.value);
};


// normal: select next setting
// hat down: select next sound
q.nktl.elAt( \kn, 0, (4..7)).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		var relStep = (el.deviceValue - el.prevValue).sign;
		if (q.nktl.elAt( \bt, 0, 1, (4..7)[i]).isOn) {
			// next sound
			q.slots.stepNext(i, relStep);
		} {
			// next preset
			q.stepNdefPreInf(ndef, relStep);
		};
	};
};

