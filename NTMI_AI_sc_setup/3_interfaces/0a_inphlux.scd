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

NTMI.inph.couple = { |dict, obj|
	var objName = obj.key;
	NTMI.inph.decoupled.remove(objName);
	if (NTMI.slots.nowPlaying.includes(obj)) {
		if (NTMI.inphlux.action.funcDict[objName].isNil) {
			// object is new: attach it
			NTMI.inphlux.attachMapped(obj);
		} {
			// if known, then just enable it:
			NTMI.inphlux.action.enable(objName);
		};
		"coupled: %\n".postf(objName);
	} {
		"will be coupled: %\n".postf(objName);
	};
};

// only disable func, keep func and data around
NTMI.inph.decouple = { |dict, obj|
	var objName = obj.key;
	NTMI.inphlux.action.disable(objName);
	NTMI.inph.decoupled.add(objName);
	"decoupled: %\n".postf(objName);
};

/*
NTMI.inphlux.action.activeNames
NTMI.inph.couple(Ndef(\revFB));
NTMI.inph.decouple(Ndef(\revFB));
*/

// clutch and unclutch an object from influx
// accessible from ntmi by hold-enc+slotbut
// how to show un/clutch on mainstage gui?

NTMI.inph.clutch = { |dict, obj|
	var objName = obj.key;
	// if this object was decoupled, couple it now
	if (NTMI.inph.decoupled.includes(objName)) {
		NTMI.inph.decoupled.remove(objName);
		if (NTMI.slots.nowPlaying.includes(obj)) {
			NTMI.inph.couple(obj)
		}
	} {
		// if coupled
		NTMI.inph.decouple(obj)
	};
};


/**
inIndices is which influx inputs,
diffs is the deltas to apply to each input for the changeVector,
and zoom is  a scale factor.

MFdef(\setRelInf).(
	theInfluxIndices addressed by this group of elements,
    the delta values for these influx inputs,
	and the zoom factor, often NTMI.zoom * NTMI.<intfName>.zoom
);

MFdef(\setRelInf).([1, 2], [0.03, -0.05], 1);
**/

NTMI.inph.toSetNow = {
	NTMI.slots.nowPlaying.select { |ndef|
		NTMI.inph.decoupled.includes(ndef.key).not
	}
};

MFdef(\setRelInf).add(\set, { |inIndices, diffs, zoom = 0.5|
	var vector;
	var ndefsToSet = NTMI.inph.toSetNow;
	// "*** in setRelInf: ".postln;
	// [inIndices, diffs, zoom].postln;
	if (ndefsToSet.notEmpty) {
		vector = NTMI.inphlux.changeVector(inIndices, diffs, zoom);
		ndefsToSet.do { |ndef|
			var params = ndef.getHalo.namesToInflux ? { ndef.controlKeys };
			var deltaPairs = [params, vector.keep(params.size)].flop;
			MFdef(\relSet).(ndef, deltaPairs);
		}
	}
});


/* toggles on/off
NTMI.inph.clutch(Ndef(\cat))
NTMI.inph.clutch(Ndef(\formSing))
*/
