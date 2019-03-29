// q.stepNdefPreInf = { |q, ndef, inc = 1|
// 	var pre = NdefPreset(ndef.key);
// 	var currIndex = pre.getHalo(\preIndex) ? 0;
// 	var nextIndex = (currIndex + inc).asInteger;
// 	var nextSetName = pre.getSetNames.wrapAt(nextIndex);
// 	pre.addHalo(\preIndex, nextIndex);
// 	pre.addHalo(\offsetPreName, nextSetName);
// 	q.inphlux.offsetsFromPreset(*[pre, nextSetName].postcs);
// 	"";
// };

q.stepNdefPreInf = { |q, ndef, inc = 1|
	var pre = NdefPreset(ndef.key);
	var nextNames = pre.getSetNames.reject(_ == \curr);
	var currName, currIndex, nextIndex, nextName;
	if (nextNames.isEmpty) {
		"*** % has no settings yet, so it cannot switch.\n".postf(pre);
	} {
		currName = pre.currSet.key;
		currIndex = nextNames.indexOf(currName) ? 0;
		nextIndex = currIndex + inc % nextNames.size;
		nextName = nextNames[nextIndex];
		"*** % next: % for preset and inphlux offsets.% %\n\n".postf(pre, nextName.cs);
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