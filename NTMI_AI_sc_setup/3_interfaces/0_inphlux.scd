// NEW INFLUX  X-OSC: :
//

q = q ? ();
q.inph = q.inph ? ();
q.inphlux = Influx(9+8, 18);
// x, y, x,  w, v, u //


q.resetInphl = { |q, infl|
	infl.set(*infl.inNames.collect([_, 0]).flat);
};

q.inph.actives = q.ndefs;

q.makeCurr = { |q, index, othersOff = true|
	defer {
		q.currxoscPx = q.ndefs[index];
		"q.currxoscPx: %\n".postf(q.currxoscPx);
		q.currxoscPx.play(0);
		if(othersOff) {
			q.ndefs.do { |ndef| if (ndef == q.currxoscPx) { ndef.stop } };
		};

		q.inphlux.attachMapped(q.currxoscPx);
	};
};

/*
q.makeCurr(4.rand, true);
*/
q.makeCurr(0);


q.makePast = { |q, index|
	defer { var others;
		var thisPx = q.ndefs[index];
		"sw off thisPx: %\n".postf(thisPx);
		thisPx.stop(0.1);
		q.inphGui.attachButtons[index].valueAction_(0);
	};
};
/*
q.makePast(4.rand.postln);
*/

// q.resetInphl(q.inphlux);
// q.inphlux.resetInvals;

// fi a Start ...

q.seedRandInfl = {|q, infl, seed=2011|
	var d = thisThread.randData;
	thisThread.randSeed_(seed);
	infl.rand;
	thisThread.randData_(d);
};

// initialize here!
q.seedRandInfl(q.inphlux, 2011);

// set center a random preset
q.centerToRandPreset = { |q, infl, preset|
	var nuP = preset.getSetNames.choose.postln;
	infl.offsetsFromPreset(preset, nuP);
	q.inphlux.resetInvals;
	preset.setCurr(nuP);
	nuP;
};

// set center to a specific preset
q.centerToPreset = { |q, infl, preset, presNr=1|
	var sez = preset.settings;
	var nuP = sez.wrapAt(presNr).key.postln;
	infl.offsetsFromPreset(preset, nuP);
	q.resetInphl(infl);
	preset.setCurr(nuP);
	nuP;
};

q.centerToCurrent = {|q, infl, px|
	infl.offsetsFromProxy(px);
	q.resetInphl(infl);
};

q.centerToNewRandSeed = {|q, infl, preset, seed=2011, much=1|
	var d = thisThread.randData;
	thisThread.randSeed_(seed);
	preset.setRand(much);
	infl.offsetsFromProxy(preset.proxy);
	q.resetInphl(infl);
	thisThread.randData_(d);
	seed
};


