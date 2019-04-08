/*
// using q.ndefs as list of the 8 ndefs to control from nano scene 1

MKtl.find(\midi);
MIDIFunc.trace(true);
MIDIFunc.trace(false);

// MKtlDesc.postLoadable;

!! conflict with slider 1, Scene 3
should be CC 85, not 2
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


/*
q.nk.ktl.elements[2][0][0];// buttons
q.nk.ktl.elements['button'], i).elements;
q.nk.ktl.elementAt(\sl, 2).elements;
q.nk.ktl.elementAt(\bt, 2, 0, 0)
*/