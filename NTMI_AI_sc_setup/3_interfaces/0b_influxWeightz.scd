/*

Hand/Rand-make 8 weights presets for influx,
so we can step thru them for different instrument feel.

////////  tests
// attach these functions to your (HW/SW) Buttons:
NTMI.inph.stepWPre(1); // next
NTMI.inphlux.presets.findKeyForValue(NTMI.inphlux.weights);
NTMI.inph.stepWPre(-1); // prev
NTMI.inph.setWPreIndex;   // rand
NTMI.inph.setWPreIndex(5);   // jump to specific

NTMI.inphlux.weights.round(0.0001); // get current ones
NTMI.inphlux.outOffsets;


************ ToDo / Ideas ***********
- outOffsets,
- offsetsFromProxy
- inScaler for controller zooming effect

- maybe a mix of inScaler, weights and outOffsets, all in one saveable preset?
- a fine, simple way to generate new ones and store beloved ones?
e.g. 4 buttons:
- propose new
- store (auto-generated name (date))
- recall previous preset
- recall next preset

*/

// setup
NTMI.inph = NTMI.inph ? ();

///// find your favorite numbers for making weights by trying them out
// NTMI.inph.put(\randSeeds, [ 3, 12, 45, 42, 37, 86, 98, 111, 151, rrand(0, 1000).postln]);
// //// e.g. these
// [ 3, 12, 45, 42, 37, 86, { rrand(0, 1000) }, \diagL ];

// NTMI.prefs.active.influxPresets = [1, 2, 3, 4, 5, 6, 7, 8];

NTMI.inph.randSeeds =
NTMI.prefs.active.influxPresets ? NTMI.prefs.default.influxPresets;

// clip to max 7 presets, so we can use the 6 back LED colors.
if (NTMI.inph.randSeeds.size > 7) {
	"*** influx presets can only be max 7!\n"
	"from %,\n".postf(NTMI.inph.randSeeds);
	NTMI.inph.randSeeds = NTMI.inph.randSeeds.keep(7);
	"keeping %.\n".postf(NTMI.inph.randSeeds);
};

// create a number of seeded random weights and store them in presets
// keys are integers 0..n-1
(
NTMI.inph.randSeeds.do { |seed|
	seed = seed.value;
	if (seed.isNumber) {
		{
			NTMI.inphlux.rand;
			NTMI.inphlux.presets.put(seed, NTMI.inphlux.weights)
		}.valueSeed(i)
	}
};

NTMI.inph.backupWeights = NTMI.inphlux.presets.deepCopy;

/*
which influx input offsets to use?
amptweaked ins are are 8 (nUFO nose up/down),
and 10 (nUFO left mid finger power)
and 14 (nUFO right mid finger, break).
so with offset 1, last slider becomes amp control,
but all sliders overlap with nUFO ...
-> for nufo setups, use offset 9, for non-nufo, use offset 1
*/

NTMI.inph.sliderOffset = NTMI.inph.sliderOffset ? 1;

/////////// BIG AMP TWEAK:
/////////// comment out if you dont like it!
NTMI.inph.ampFirstTweakOn = {
	NTMI.inphlux.presets.keysValuesDo { |key, weights|
		// decouple amp:
		// decrease amp influence on all
		weights[0] = NTMI.inph.backupWeights[key][0] * 0.25;

		// right side: middle finger pad is gas pedal
		weights[0][14] = 1.0;
		// left  side: middle finger pad is brake pedal
		weights[0][10] = -1.0;

		// nose down is full blast, laying it on back takes volume down
		weights[0][8] = -1.0;

	};
	NTMI.inph.ampTweakIsOn = true;
};

// restore orig NTMI.inphlux.presets
NTMI.inph.ampFirstTweakOff = {
	NTMI.inph.backupWeights.keysValuesDo { |key, val|
		NTMI.inphlux.presets.put(key, val.copy);
	};
	NTMI.inph.ampTweakIsOn = false;
};

NTMI.inph.inphTanhOn = {
	// and compress output values by tanh, so we clip later?
	NTMI.inphlux.addProc(\base, { |val| val.tanh * 1.1 });
	NTMI.inph.tanhIsOn = true;
};

NTMI.inph.inphTanhOff = {
	// and compress output values by tanh, so we clip later?
	NTMI.inphlux.addProc(\base, nil);
	NTMI.inph.tanhIsOn = false;
};

NTMI.inph.ampFirstTweakOn;
NTMI.inph.inphTanhOn;

/*
NTMI.inph.ampFirstTweakOff;
NTMI.inph.inphTanhOff;
*/

///////// BIG AMP TWEAK ends.



// store num pres and current
NTMI.inph.put(\numPres, NTMI.inph.randSeeds.size);
NTMI.inph.put(\presIndex,
	NTMI.inph.randSeeds.indexOf(NTMI.prefs.active.influxPreset) ?
	NTMI.inph.randSeeds.size.rand
);

NTMI.inph.alpha = 0.7;
// colors attributed to the 6 presets,
// so we can set the colors on the nufo LEDs
NTMI.inph.presetCols = 6.collect {|i|
	var col = Color.hsv(i/6.0, 1, 1, 1);
	var sum = col.red + col.blue + col.green;
	// tone down mixed colors for eye comfort
	Color.fromArray(col.asArray.keep(3) * (sum ** -0.38) ++ [NTMI.inph.alpha])
}.add(Color.black.alpha_(NTMI.inph.alpha));

NTMI.inph.counterCols = 6.collect {|i|
	Color.hsv( (i/6.0 + 0.5).wrap(0,1), 1, 1, 1);
}.add(Color.white).collect(_.asArray);



// set weights preset by index: number is wrapped index in NTMI.inph.randSeeds
NTMI.inph.setWPreIndex = { |dict, index|
	var numPres = NTMI.inph.randSeeds.size;
	var nuIndex = (index ? NTMI.inph.at(\presIndex) ? 0).asInteger % numPres;
	var nuPreKey = NTMI.inph.randSeeds[nuIndex];
	var nuPreset = NTMI.inphlux.presets[nuPreKey];
	"*** INFLUX preset % - magicNumber % - ".postf(nuIndex, nuPreKey);
	// nuPreset.round(0.001).printAll;
	NTMI.inph.put(\presIndex, nuIndex);
	NTMI.inphlux.setwPre(nuPreKey);
	NTMI.inph.currPresetCol = NTMI.inph.presetCols @@ NTMI.inph.at(\presIndex);
	NTMI.inph.currCounterCol = NTMI.inph.counterCols @@ NTMI.inph.at(\presIndex);

	NTMI.inph.currPresetCol.postln;
	// send this to OSC/Modality device ! (RGB Col)
	if (MKtl.all[\nUFO].notNil){ NTMI.inph.sendInphPre };

	if (MKtl.all[\xosc].notNil) {
		try {
			MKtl(\xosc).elAt(\led, \6).value_(nuIndex / NTMI.inph.randSeeds.size );
			MKtl(\xosc).elAt(\led, \7).value_(nuIndex / NTMI.inph.randSeeds.size );
		};
	};
};

// nil -> rand, -1 is down, 1 is up
NTMI.inph.stepWPre = { |dict, inc|
	var nuIndex;
	inc = inc ?? { "rand: ".post; rrand(1, NTMI.inph.randSeeds.size).postln };
	nuIndex = NTMI.inph.at(\presIndex) + inc % NTMI.inph.randSeeds.size;
	NTMI.inph.setWPreIndex(nuIndex);
};

/// INIT!
NTMI.inph.setWPreIndex(NTMI.inph.at(\presIndex));

);
