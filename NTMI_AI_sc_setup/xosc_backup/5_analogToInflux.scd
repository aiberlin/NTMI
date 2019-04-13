///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// ANALOG INS Touchmod
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

//neu - remove weird crosstalk from each input to next
(
q.inphlux.addHalo(\padNames, q.inphlux.inNames.copyRange(9, 16));

MFdef(\touchToInph).add(\set, {
	var influx = q.inphlux;
	var pads = MKtl(\xosc).elAt(\pads8);
	var padInNames = q.inphlux.getHalo(\padNames);
	var keysValues = pads.collect { |pad, i|
		[ padInNames[i], pad.value]
	}.flat;
	q.inphlux.set(*keysValues);
});

OSCdef(\xana, { |msg|
	var values = msg.drop(1);
	var influxKeysVals;
	var xtalkFactor = 0.5;
	// andere sensor vieleicht passt andere nummer
	// value[1] = value[1].linlin(value[0] * 0.5, 1, 0, 1);
	// MAGIC crosstalk compensation of
	//////// adc Mar 2019 - still seems an improvement
	(15..1).do { |i|
		values[i] = values[i].linlin(values[i - 1] * xtalkFactor, 1, 0, 1);
	};

	q.osc.rawPads = values[8..];

	// q.zero.pads is the rest state of the pads
	// use it to stretch to a range of 0-1
	(8..15).do { |i|
		var rawval = values[i];
		var zeroOffset = q.zero.pads.asArray.wrapAt(i);
		var stretched = rawval.linlin(zeroOffset, 0.9, 0, 1);
		values.put(i,stretched);
	};

	MKtl(\xosc).elAt('inA').value_(values);
	MFdef(\touchToInph).value;

	MKtl(\xosc).elAt('inA', 7).doAction;

}, '/inputs/analogue').permanent_(true);
);

// individual pad action - useful for guis
/// do global set only once, from MFdef(\touchToInph)
MKtl(\xosc).elAt(\pads8).do { |pad, i|
	pad.action.add(\setInflux, {|ana|
		var name = 	q.inphlux.getHalo(\padNames).clipAt(i);
		q.inphlux.set(name, ana.value.pow(3));
		//.pow(6));
		// the pow(6) helps toflatten the steep curve of the FSRs as they are now.
		ana.value
	})
};


/*

MFdef(\xoscFunc).add(\setInphlux, {
var values = MKtl(\xosc).elAt(\accel).value.unibi ++ MKtl(\xosc).elAt(\gyro).value.unibi ++ MKtl(\xosc).elAt(\magnet).value.unibi ;
var names = q.inphlux.inNames;
var keysvals = [names, values * q.inph.scale].flop.flat;
q.inphlux.set(*keysvals);
});

q.ndefs.do { |ndef, i|
MKtl(\xosc).elAt(\inA, [8,9,10,11][i]).action.add(\setNdef, { |ana|
ndef.vol_( (ana.value - 0.0).cubed.clip(0, 1))
});
};

[8,9,10,11].do{|i|	MKtl(\xosc).elAt(\inA, i).action.disable(\setNdef) };
[8,9,10,11].do{|i|	MKtl(\xosc).elAt(\inA, i).action.enable(\setNdef) };
*/
