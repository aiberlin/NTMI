//
/*
slotmachine has 4 slots with playable objects
We assume these are all Ndefs for now.
When an object is added,
- the old one stops, and is removed from influx,
- and the new one plays and is attached to influx.


NdefMixer(s, 24);
q.ndefs;
q.slots.actives;
q.slots.playAt(0)
q.slots.stopAt(0)

q.slots.playAt(1)
q.slots.stopAt(1)

q.slots.playAt(3)
q.slots.stepNext(3)

////// new tests:

"testing slots ...".postln;
q.slots.choices.collect(_.size);

q.slots.actives;
q.slots.addActive(0, Ndef(\dog));

q.slots.actives.put(0, Ndef(\revFB));
q.slots.addActive(0, Ndef(\revFB));
q.slots.addActive(0, Ndef(\cat));

q.slots.updateChoices;
q.slots.choices;


q.slots.addActive(4,)
q.slots.addActive(3, Ndef(\kiteHi))

q.slots.chooseNext(0);

q.inphlux.action.activeNames;
q.inphlux.action.disable(q.inphlux.action.activeNames.copy);

*/

q.slots = q.slots ? ();
q.slots.actives = q.ndefs;
// use this global fadeoutTime for ndef.stop(fadeoutTime);
q.slots.fadeoutTime = 0.2;
q.slots.defaultVol = 0.25;


q.slots.nowPlaying = {
	q.slots.actives.select { |ndef| ndef.monitor.isPlaying  };
};

q.slots.playAt = { |sl, index|
	var obj = q.slots.actives[index];
	var vol = if (obj.monitor.isNil, q.slots.defaultVol, { obj.vol });
	"% at % plays now.\n".postf(obj, index);
	obj.play(vol: vol);
	q.inphlux.attachMapped(obj);
};

// maybe make a flag for stop or end?
q.slots.stopAt = { |sl, index|
	var obj = q.slots.actives[index];
	if (obj.isPlaying) {
		"% at % ends now.\n".postf(obj, index);
		obj.end(q.slots.fadeoutTime);
	};
	try { q.inphlux.removeMapped(obj.key) };
};

q.slots.toggleAt = { |sl, index|
	var obj = q.slots.actives[index];
	var isPlaying = if (obj.isKindOf(NodeProxy))
		{ obj.monitor.isPlaying }
		{ obj.isPlaying };

	if (isPlaying) {
		q.slots.stopAt(index);
		false
	} {
		q.slots.playAt(index);
		true
	}
};

q.slots.checkIndex = { |sl, index|
	var res = index.isNumber and: { index.inclusivelyBetween(0, q.slots.actives.lastIndex) };
	if (res.not) { "slots index must be between 0 and 3".postln };
	res;
};

// super defensive
q.slots.addActive = { |sl, index, obj|
	case
	{ q.slots.checkIndex(index).not } { "q.slots.addActive - index not valid: %\n".postf(index) }
	{ obj.respondsTo(\key).not } { "q.slots.addActive - obj has no key: %\n".postf(obj) }
	{ q.slots.choices[index].includes(obj.key).not } { "q.slots.addActive - obj is not in choices: %\n".postf(obj) }
	{		// all is well
		if (q.slots.actives[index] != obj) {
			q.slots.stopAt(index); // stop the old one
		};
		q.slots.actives.put(index, obj);
		q.slots.stopAt(index); // stop the new one
		q.slots.updateChoices;
	}
};

q.slots.updateChoices = {
	q.slots.choices = q.slots.actives.collect { |ndef, i|
		q.process.allNames.reject { |name|
			var takenKeys = q.slots.actives.collect(_.key);
			takenKeys.remove(ndef.key);
			takenKeys.includes(name)
		}
	};
	q.slots.choices;
};

q.slots.chooseNext = { |sl, index|
	q.slots.stepNext(index, nil);
};

q.slots.stepNext = { |sl, index, incr|
	var candidates, myindex, nextindex, nextname;
	if (q.slots.checkIndex(index)) {
		candidates = q.slots.choices[index];
		incr = incr ?? {
			"rand incr ...".postln;
			rrand(1, candidates.lastIndex);
		};
		myindex = candidates.indexOf(q.slots.actives[index].key);
		nextindex = myindex + incr % candidates.size;
		nextname = candidates[nextindex];
		"next  sound in slot % : % \n".postf(index, nextname);
		// ndef is dogy here, hmmm
		q.slots.addActive(index, Ndef(nextname));
	};
};

//// init just to make sure
q.slots.updateChoices;
q.slots.actives.do { |ndef, i|
	q.slots.addActive(i, ndef);
};

q.slots.test = {
	var passed = true;
	q.slots.actives.do { |ndef, i|
		q.slots.choices.do { |choices, j|
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

