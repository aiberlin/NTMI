// NEW INFLUX  X-OSC: :
//

q = q ? ();
q.inph = q.inph ? ();
q.inphlux = Influx(9+8, 20);

q.inph.seedRand = {|q, infl, seed=2011|
	var d = thisThread.randData;
	thisThread.randSeed_(seed);
	infl.rand;
	thisThread.randData_(d);
};

// initialize here!
q.inph.seedRand(q.inphlux, 2011);

// set center a random preset
q.inph.centerToRandPreset = { |q, infl, preset|
	var nuP = preset.getSetNames.choose.postln;
	infl.offsetsFromPreset(preset, nuP);
	q.inphlux.resetInvals;
	preset.setCurr(nuP).setProxy(nuP);
	nuP;
};

// set center to a specific preset
q.inph.centerToPreset = { |q, infl, preset, presNr=1|
	var sez = preset.settings;
	var nuP = sez.wrapAt(presNr).key.postln;
	infl.offsetsFromPreset(preset, nuP);
	q.inphlux.resetInvals;
	preset.setCurr(nuP).setProxy(nuP);
	nuP;
};

q.inph.centerToCurrent = {|q, infl, px|
	infl.offsetsFromProxy(px);
	q.inphlux.resetInvals;
};

q.inph.centerToNewRandSeed = {|q, infl, preset, seed=2011, much=1|
	var d = thisThread.randData;
	thisThread.randSeed_(seed);
	preset.setRand(much);
	infl.offsetsFromProxy(preset.proxy);
	q.inphlux.resetInvals;
	thisThread.randData_(d);
	seed
};

q.inph.decoupled = Set[];

MFdef(\inphCouple).add(\attachOrEnable, { |obj|
	var objName = obj.key;
	if (q.inphlux.action.funcDict[objName].isNil) {
		// object is new: attach it
		q.inphlux.attachMapped(obj)
	} {
		// if known, then just enable it:
		q.inphlux.action.enable(objName)
	};
});

// only disable func, keep func and data around
MFdef(\inphDecouple).add(\disable, { |obj|
	var objName = obj.key;
	q.inphlux.action.disable(objName.postln)
});

/*
MFdef(\inphCouple).(Ndef(\revFB));
MFdef(\inphDecouple).(Ndef(\revFB));
*/

// clutch and unclutch an object from influx
// accessible from ntmi by hold-enc+slotbut
// how to show un/clutch on mainstage gui?

MFdef(\clutch).add(\toggle, { |obj|
	var objName = obj.key;
	// if this object was decoupled, couple it now
	if (q.inph.decoupled.includes(objName)) {
		q.inph.decoupled.remove(objName);
		if (q.slots.nowPlaying.includes(obj)) {
			MFdef(\inphCouple).(obj)
		}
	} {
		// if coupled,
		q.inph.decoupled.add(objName);
		MFdef(\inphDecouple).(obj)
	};
	"q.inph.decoupled: % \n".postf(q.inph.decoupled);
	"q.inphlux - active & coupled: % \n".postf(q.inphlux.action.activeNames);
});

/* toggles on/off
MFdef(\clutch).value(Ndef(\cat))
MFdef(\clutch).value(Ndef(\formSing))
*/
