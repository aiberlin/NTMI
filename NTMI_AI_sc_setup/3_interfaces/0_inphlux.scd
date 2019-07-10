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
	preset.setCurr(nuP);
	nuP;
};

// set center to a specific preset
q.inph.centerToPreset = { |q, infl, preset, presNr=1|
	var sez = preset.settings;
	var nuP = sez.wrapAt(presNr).key.postln;
	infl.offsetsFromPreset(preset, nuP);
	q.inphlux.resetInvals;
	preset.setCurr(nuP);
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

// clutch and unclutch an object from influx
// will be accessible from ntmi by hold-enc+slotbut
MFdef(\clutch).add(\toggle, { |obj|
	obj.postln;
	if (q.inphlux.action.activeNames.includes(obj.key)) {
		"influx: detaching %\n".postf(obj);
		q.inphlux.detach(obj.key);
	} {
		"influx: attaching %\n".postf(obj);
		q.inphlux.attachMapped(obj);
	}
});
/* toggles on?off
MFdef(\clutch).value(Ndef(\formSing))
MFdef(\clutch).value(Ndef(\formSing))
*/
