q.stepNdefPreInf = { |q, ndef, inc = 1|
	var pre = NdefPreset(ndef.key);
	var currIndex = pre.getHalo(\preIndex) ? 0;
	var nextIndex = (currIndex + inc).asInteger;
	var nextSetName = pre.getSetNames.wrapAt(nextIndex);
	pre.addHalo(\preIndex, nextIndex);
	pre.addHalo(\offsetPreName, nextSetName);
	q.inphlux.offsetsFromPreset(*[pre, nextSetName].postcs);
	"";
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