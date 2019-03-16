// setup
q = q? ();

// find your favorite numbers for making weights by trying them out
// q.inphlux.addHalo(\randSeeds, [ 3, 12, 45, 42, 37, 86, 98, 111, 151, rrand(0, 1000).postln]);
q.inphlux.addHalo(\randSeeds, [ 3, 12, 45, 42, 37, 86, 98, rrand(0, 1000).postln]);

// create a number of seeded random weights and store them in presets
// keys are integers 0..n-1
q.inphlux.getHalo(\randSeeds).size;
(
q.inphlux.getHalo(\randSeeds).do { |i|
	{
		q.inphlux.rand;
		q.inphlux.presets.put(i, q.inphlux.weights)
	}.valueSeed(i)
};

// store num pres and current
q.inphlux.addHalo(\numPres, q.inphlux.getHalo(\randSeeds).size);
q.inphlux.addHalo(\presIndex, 0);
q.inphlux.setwPre(0);

// colors attributed to the n presets
q.presetCols = q.inphlux.getHalo(\randSeeds).size.collect{|i| Color.hsv(i/ q.inphlux.getHalo(\randSeeds).size + 0.0, 1, 1, 1)};


// dynamic - iterates over ALL CURRENTLY existing presets.
q.stepWeights = {|q, inc=1|
	var nuIndex = q.inphlux.getHalo(\presIndex) + inc % q.inphlux.getHalo(\randSeeds).size;
	var nuPres = q.inphlux.presets.keys.asArray.sort @@ nuIndex;
	q.inphlux.addHalo(\presIndex, nuIndex);
	">>> setting inphlux to preset % with magic Number %\n".postf(nuIndex, nuPres);
	q.inphlux.setwPre(nuPres);

	q.currPresetCol = q.presetCols @@ q.inphlux.getHalo(\presIndex);
	// send this to OSC/Modality device ! (RGB Col)
	"curr Color: ".post; (q.currPresetCol.asArray * 255).keep(3).asInteger.postln;
	try{
		x.elAt(\led, \6).value_(nuIndex / q.inphlux.getHalo(\randSeeds).size );
		x.elAt(\led, \7).value_(nuIndex / q.inphlux.getHalo(\randSeeds).size );
	};
};
);


q.inphlux.weights.round(0.0001); // get current ones
q.inphlux.outOffsets;
// attach these 2 functions to your (HW/SW) Button
q.stepWeights(1);
q.stepWeights(-1);

/*q.currPresetCol.addDependant{|o| "flitz!!".postcln; };
SimpleController*/

/*

ToDo / Ideas
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