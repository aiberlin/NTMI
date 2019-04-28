/*

Hand/Rand-make 8 weights presets for influx,
so we can step thru them for different instrument feel.

////////  tests
// attach these functions to your (HW/SW) Buttons:
MFdef(\stepInphWPre).value(1); // next
q.inphlux.presets.findKeyForValue(q.inphlux.weights);
MFdef(\stepInphWPre).value(-1); // prev
MFdef(\setInphWPre).value;   // rand
MFdef(\setInphWPre).value(5);   // jump to specific

q.inphlux.weights.round(0.0001); // get current ones
q.inphlux.outOffsets;


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
q = q ? ();
q.inph = q.inph ? ();

// find your favorite numbers for making weights by trying them out
// q.inph.put(\randSeeds, [ 3, 12, 45, 42, 37, 86, 98, 111, 151, rrand(0, 1000).postln]);
q.inph.randSeeds = q.prefs.active.influxPresets ?? {
	[ 3, 12, 45, 42, 37, 86, 98, rrand(0, 1000)]
};

// create a number of seeded random weights and store them in presets
// keys are integers 0..n-1
q.inph.randSeeds.size;
(
q.inph.randSeeds.do { |i|
	{
		q.inphlux.rand;
		q.inphlux.presets.put(i, q.inphlux.weights)
	}.valueSeed(i)
};

// store num pres and current
q.inph.put(\numPres, q.inph.randSeeds.size);
q.inph.put(\presIndex, q.inph.randSeeds.indexOf(q.prefs.active.influxPreset) ? 0);
q.inphlux.setwPre(q.prefs.active.influxPreset);

q.inph.alpha = 0.8;
// colors attributed to the n presets
q.inph.presetCols = q.inph.randSeeds.size.collect {|i|
	var col = Color.hsv(i/ q.inph.randSeeds.size + 0.0, 1, 1, 1);
	var sum = col.red + col.blue + col.green;
	// tone down mixed colors for eye comfort
	Color.fromArray(col.asArray.keep(3) * (sum ** -0.38) ++ [q.inph.alpha])
};

// set weights preset by index: number is wrapped index in q.inph.randSeeds
MFdef(\setInphWPre).add(\set, { |index|
	var numPres = q.inph.randSeeds.size;
	var nuIndex = (index ? q.inph.at(\presIndex) ? 0).asInteger % numPres;
	var nuPreKey = q.inph.randSeeds[nuIndex];
	var nuPreset = q.inphlux.presets[nuPreKey];
	">>> setting inphlux to preset % with magic Number %:\n".postf(nuIndex, nuPreKey);
	// nuPreset.round(0.001).printAll;
	q.inph.put(\presIndex, nuIndex);
	q.inphlux.setwPre(nuPreKey);
	q.inph.currPresetCol = q.inph.presetCols @@ q.inph.at(\presIndex);
	// send this to OSC/Modality device ! (RGB Col)
	"curr Color: ".post; (q.inph.currPresetCol.asArray * 255).keep(3).asInteger.postln;
	try {
		MKtl(\xosc).elAt(\led, \6).value_(nuIndex / q.inph.randSeeds.size );
		MKtl(\xosc).elAt(\led, \7).value_(nuIndex / q.inph.randSeeds.size );
	};
});

// nil -> rand, -1 is down, 1 is up
MFdef(\stepInphWPre).add(\inc, { |inc = 1|
	var nuIndex;
	inc = inc ?? { rrand(1, q.inph.randSeeds.size) };
	nuIndex = q.inph.at(\presIndex) + inc % q.inph.randSeeds.size;
	MFdef(\setInphWPre).value(nuIndex);
});

/// INIT!
MFdef(\setInphWPre).value(q.inph.at(\presIndex));

);
