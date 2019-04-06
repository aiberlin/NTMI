
// inc nil: rand, 1 is next, 2 is prev in list
q.stepNdefPreInf = { |q, ndef, inc|
	var pre = NdefPreset(ndef.key);
	var nextNames = pre.getSetNames.reject(_ == \curr);
	var currName, currIndex, nextIndex, nextName;
	if (nextNames.isEmpty) {
		"*** % has no settings yet, so it cannot switch.\n".postf(pre);
	} {
		currName = pre.currSet.key;
		currIndex = nextNames.indexOf(currName) ? 0;
		inc = inc ?? {
			"rand".postln;
			rrand(1, nextNames.lastIndex)
		};
		nextIndex = currIndex + inc % nextNames.size;
		nextName = nextNames[nextIndex];
		">>> % setting: %\n\n".postf(pre, nextName.cs);
		pre.setCurr(nextName);
		q.inphlux.offsetsFromPreset(*[pre, nextName]);
	};
};

/*
q.stepNdefPreInf(NdefPreset(\bleepo));
q.stepNdefPreInf(Ndef(\bleepo), -1);

NdefPreset(\moogSing).getCurrUni;
f = q.inphlux.offsetsFromPreset(NdefPreset(\moogSing), \curr).moogSing;
g = q.inphlux.offsetsFromPreset(NdefPreset(\moogSing), \curr).moogSing;
q.inphlux.offsetsFromPreset(NdefPreset(\bleepo), \curr);
NdefPreset(\moogSing).getSetNames;
*/