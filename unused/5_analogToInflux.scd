///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// ANALOG INS Touchmod
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

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

////// this is the action that gets triggered
////// when values come in from the xosc -
////// use this to compensate for crosstalk,
////// and sending the final values once.

MKtl(\xosc).collAt('aIn').groupAction = nil;

MKtl(\xosc).collAt('aIn').groupAction = { |coll|
	var values = coll.value;
	var xtalkFactor = 0.5;

	// // MAGIC crosstalk compensation - adc Mar 2019 - seems an improvement
	// // value[1] = value[1].linlin(value[0] * 0.5, 1, 0, 1);
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

	// set to the compensated values, no action
	MKtl(\xosc).elAt('inA').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\touchToInph).value;
	// and explicitly trigger zoom action
	MKtl(\xosc).elAt('inA', 7).doAction;

};

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

);

