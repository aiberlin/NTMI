//
/*
slotmachine has 4 slots with playable objects
We assume these are all Ndefs for now.
When an object is added,
- the old one stops, and is removed from influx,
- and the new one plays and is attached to influx.


NdefMixer(s, 24);
NTMI.ndefs;
NTMI.slots.actives;
NTMI.slots.playAt(0)
NTMI.slots.stopAt(0)

NTMI.slots.playAt(1)
NTMI.slots.stopAt(1)

NTMI.slots.playAt(3)
NTMI.slots.stepNext(3)

////// new tests:

"testing slots ...".postln;
NTMI.slots.choices.collect(_.size);

NTMI.slots.actives;
NTMI.slots.addActive(0, Ndef(\dog));

NTMI.slots.actives.put(0, Ndef(\revFB));
NTMI.slots.addActive(0, Ndef(\revFB));
NTMI.slots.addActive(0, Ndef(\cat));

NTMI.slots.updateChoices;
NTMI.slots.choices;


NTMI.slots.addActive(4,)
NTMI.slots.addActive(3, Ndef(\kiteHi))

NTMI.slots.chooseNext(0);

NTMI.inphlux.action.activeNames;
NTMI.inphlux.action.disable(NTMI.inphlux.action.activeNames.copy);

*/

NTMI.slots = NTMI.slots ? ();
NTMI.slots.actives = NTMI.ndefs;
// use this global fadeoutTime for ndef.stop(fadeoutTime);
NTMI.slots.fadeoutTime = NTMI.slots.fadeoutTime ? 0.2;
NTMI.slots.defaultVol = NTMI.slots.defaultVol ? 0.25;
NTMI.slots.defaultAmp = NTMI.slots.defaultAmp ? 0.25;

NTMI.slots.zz = [ Ndef(\zz1), Ndef(\zz2), Ndef(\zz3), Ndef(\zz4)];

NTMI.slots.nowPlaying = {
	NTMI.slots.actives.select { |ndef| ndef.monitor.isPlaying  };
};

NTMI.processes.do(_.vol_(NTMI.slots.defaultVol));


NTMI.slots.playAt = { |sl, index|
	var obj = NTMI.slots.actives[index];
	var pre = NdefPreset(obj.key);
	var currPreName = pre.currSet.key;
	var vol = if (obj.monitor.isNil, NTMI.slots.defaultVol, { obj.vol });
	"SLOT %: % starts - ".postf(index, obj);
	obj.rebuild.play(vol: vol);
	obj.set(\amp, NTMI.slots.defaultAmp);
	if ([\full, \touch].includes(NTMI.nUFO.mode)) {
		NTMI.inphlux.attachMapped(obj);
	};
	// and make sure preset is active:
	NTMI.inphlux.offsetsFromPreset(pre, currPreName);
	"using preset % as influx offset.\n".postf(currPreName.cs);
};

NTMI.slots.stopAt = { |sl, index|
	var obj = NTMI.slots.actives[index];
	if (obj.isPlaying) {
		"SLOT %: % stops.\n".postf(index, obj);
		obj.stop(NTMI.slots.fadeoutTime)
	};
	try { NTMI.inphlux.removeMapped(obj.key) };
};

NTMI.slots.endAt = { |sl, index|
	var obj = NTMI.slots.actives[index];
	if (obj.isPlaying) {
		"SLOT %: % ends.\n".postf(index, obj);
		obj.end(NTMI.slots.fadeoutTime)
	};
	try { NTMI.inphlux.removeMapped(obj.key) };
};

NTMI.slots.toggleAt = { |sl, index|
	var obj = NTMI.slots.actives[index];
	var isPlaying = if (obj.isKindOf(NodeProxy))
	{ obj.monitor.isPlaying }
	{ obj.isPlaying };

	if (isPlaying) {
		NTMI.slots.stopAt(index);
		false
	} {
		NTMI.slots.playAt(index);
		true
	}
};

NTMI.slots.checkIndex = { |sl, index|
	var res = index.isNumber and: { index.inclusivelyBetween(0, NTMI.slots.actives.lastIndex) };
	if (res.not) { "slots index must be between 0 and 3".postln };
	res;
};

// super defensive
NTMI.slots.addActive = { |sl, index, obj|
	case
	{ NTMI.slots.checkIndex(index).not } {
		"NTMI.slots.addActive - index not valid: %\n".postf(index)
	}
	{ obj.respondsTo(\key).not } {
		"NTMI.slots.addActive - obj has no key: %\n".postf(obj)
	}
	{ NTMI.slots.choices[index].includes(obj.key).not } {
		"NTMI.slots.addActive - obj is not in choices: %\n".postf(obj)
	}
	{		// all is well
		if (NTMI.slots.actives[index] != obj) {
			NTMI.slots.endAt(index); // end the old one
		};
		NTMI.slots.actives.put(index, obj);
		"slots: % source is %\n".postf(NTMI.slots.zz[index], obj);
		NTMI.slots.zz[index].postln.source = { obj.ar };
		// NTMI.slots.stopAt(index);
		NTMI.slots.updateChoices;
	}
};

NTMI.slots.updateChoices = {
	NTMI.slots.choices = NTMI.slots.actives.collect { |ndef, i|
		NTMI.process.allNames.reject { |name|
			var takenKeys = NTMI.slots.actives.collect(_.key);
			takenKeys.remove(ndef.key);
			takenKeys.includes(name)
		}
	};
	NTMI.slots.choices;
};

NTMI.slots.chooseNext = { |sl, index|
	NTMI.slots.stepNext(index, nil);
};

NTMI.slots.stepNext = { |sl, index, incr|
	var candidates, myindex, nextindex, nextname;
	if (NTMI.slots.checkIndex(index)) {
		candidates = NTMI.slots.choices[index];
		incr = incr ?? {
			"rand incr ...".postln;
			rrand(1, candidates.lastIndex);
		};
		myindex = candidates.indexOf(NTMI.slots.actives[index].key);
		nextindex = myindex + incr % candidates.size;
		nextname = candidates[nextindex];
		"SLOT % -> % \n".postf(index, nextname.cs);
		// ndef is dogy here, hmmm
		NTMI.slots.addActive(index, Ndef(nextname));
	};
};

NTMI.slots.stepActivePres = { |dict, step|
	var activeNdefs = NTMI.inphlux.action.activeNames.collect(Ndef(_));
	activeNdefs.do { |nd, j|
		NTMI.pre.stepNdefInf( nd, step );
	};
};

//// init just to make sure
NTMI.slots.updateChoices;
NTMI.slots.actives.do { |ndef, i|
	NTMI.slots.addActive(i, ndef);
};

NTMI.slots.test = {
	var passed = true;
	NTMI.slots.actives.do { |ndef, i|
		NTMI.slots.choices.do { |choices, j|
			if (i == j) {
				if (choices.includes(ndef.key).not) {
					"ndef not in its own choices".warn;
					passed = false;
					[i, j, ndef].postln
				}
			} {
				if (choices.includes(ndef.key)) {
					"ndef is available in wrong choices".warn;
					passed = false;
					[i, j, ndef].postln
				}
			}
		}
	};
	passed
};

