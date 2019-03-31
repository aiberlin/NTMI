///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// ANALOG INS Touchmod
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

x.elementsDict.keys;
//neu - remove weird crosstalk from each input to next
(
OSCdef(\xana, { |msg|
	var values = msg.drop(1);
	var xtalkFactor = 0.5;// andere sensor vieleicht passt andere nummer
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

	// values.round(0.001).postln;
	//values.reverse??.do
	values.do { |val, index|
		var elem = x.elAt('inA').at(index);
		if (elem.value != val) {
			elem.valueAction_(val);
		}
	}
}, '/inputs/analogue').permanent_(true);
);

8.do{|i|
	x.elAt('inA').at(i + 8).action.add(\setInflux, {|ana|
		var name = 	q.inphlux.inNames.clipAt(i + 9);
		q.inphlux.set(name, ana.value.pow(3)); //.pow(6));      // the pow(6) helps toflatten the steep curve of the FSRs as they are now.
		ana.value
	})
};


/*

MFdef(\xoscFunc).add(\setInphlux, {
var values = x.elAt(\accel).value.unibi ++ x.elAt(\gyro).value.unibi ++ x.elAt(\magnet).value.unibi ;
var names = q.inphlux.inNames;
var keysvals = [names, values * q.inph.scale].flop.flat;
q.inphlux.set(*keysvals);
});

q.ndefs.do { |ndef, i|
x.elAt(\inA, [8,9,10,11][i]).action.add(\setNdef, { |ana|
ndef.vol_( (ana.value - 0.0).cubed.clip(0, 1))
});
};

[8,9,10,11].do{|i|	x.elAt(\inA, i).action.disable(\setNdef) };
[8,9,10,11].do{|i|	x.elAt(\inA, i).action.enable(\setNdef) };
*/
