// NEW INFLUX  X-OSC: :
//

NTMI.inph = NTMI.inph ? ();
NTMI.inphlux = Influx(9+8, 20);

NTMI.inph.seedRand = {|q, infl, seed=2011|
	var d = thisThread.randData;
	thisThread.randSeed_(seed);
	infl.rand;
	thisThread.randData_(d);
};

// initialize here!
NTMI.inph.seedRand(NTMI.inphlux, 2011);

// set center a random preset
NTMI.inph.centerToRandPreset = { |q, infl, preset|
	var nuP = preset.getSetNames.choose.postln;
	infl.offsetsFromPreset(preset, nuP);
	NTMI.inphlux.resetInvals;
	preset.setCurr(nuP).setProxy(nuP);
	nuP;
};

// set center to a specific preset
NTMI.inph.centerToPreset = { |q, infl, preset, presNr=1|
	var sez = preset.settings;
	var nuP = sez.wrapAt(presNr).key.postln;
	infl.offsetsFromPreset(preset, nuP);
	NTMI.inphlux.resetInvals;
	preset.setCurr(nuP).setProxy(nuP);
	nuP;
};

NTMI.inph.centerToCurrent = {|q, infl, px|
	infl.offsetsFromProxy(px);
	NTMI.inphlux.resetInvals;
};

NTMI.inph.centerToNewRandSeed = {|q, infl, preset, seed=2011, much=1|
	var d = thisThread.randData;
	thisThread.randSeed_(seed);
	preset.setRand(much);
	infl.offsetsFromProxy(preset.proxy);
	NTMI.inphlux.resetInvals;
	thisThread.randData_(d);
	seed
};

NTMI.inph.decoupled = Set[];

MFdef(\inphCouple).add(\attachOrEnable, { |obj|
	var objName = obj.key;
	if (NTMI.inphlux.action.funcDict[objName].isNil) {
		// object is new: attach it
		NTMI.inphlux.attachMapped(obj)
	} {
		// if known, then just enable it:
		NTMI.inphlux.action.enable(objName)
	};
});

// only disable func, keep func and data around
MFdef(\inphDecouple).add(\disable, { |obj|
	var objName = obj.key;
	NTMI.inphlux.action.disable(objName.postln)
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
	if (NTMI.inph.decoupled.includes(objName)) {
		NTMI.inph.decoupled.remove(objName);
		if (NTMI.slots.nowPlaying.includes(obj)) {
			MFdef(\inphCouple).(obj)
		}
	} {
		// if coupled,
		NTMI.inph.decoupled.add(objName);
		MFdef(\inphDecouple).(obj)
	};
	"NTMI.inph.decoupled: % \n".postf(NTMI.inph.decoupled);
	"NTMI.inphlux - active & coupled: % \n".postf(NTMI.inphlux.action.activeNames);
});

/* toggles on/off
MFdef(\clutch).value(Ndef(\cat))
MFdef(\clutch).value(Ndef(\formSing))
*/
