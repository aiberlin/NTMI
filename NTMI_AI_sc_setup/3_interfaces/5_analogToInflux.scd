///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// ANALOG INS Touchmod
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

x.elementsDict.keys;
//neu - remove weird crosstalk from each input to next
(
OSCdef(\xana,{ |msg|
	var values = msg.drop(1);
	var xtalkFactor = 0.5;// andere sensor vieleicht passt andere nummer
	// value[1] = value[1].linlin(value[0] * 0.5, 1, 0, 1);
	// MAGIC crosstalk compensation of
	(15..1).do { |i|
		values[i] = values[i].linlin(values[i - 1] * xtalkFactor, 1, 0, 1);
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
(
// switch mode - analog in vs. IMU
q.influxWhich = true;

[\inD_4].do { |bt, i|
	x.elementsDict[bt].action.add(\front, {|bt|
		if (bt.value > 0) {
			if(  q.influxWhich )
			{
				"*** enable analox".postln;
				8.do{|i|	x.elAt('inA').at(i + 8).action.enable(\setInflux) };
				MFdef(\xoscFunc).disable( \setInphlux );
			}{
				"*** enable IMU ".postln;
				8.do{|i|	x.elAt('inA').at(i + 8).action.disable(\setInflux) };
				MFdef(\xoscFunc).enable( \setInphlux );
			};
			q.influxWhich = q.influxWhich.not;

		}
	});
};


)


MFdef(\xoscFunc).add(\setInphlux, {
var values = x.elAt(\accel).value.unibi ++ x.elAt(\gyro).value.unibi ++ x.elAt(\magnet).value.unibi ;
var names = q.inphlux.inNames;
var keysvals = [names, values * q.inphscale].flop.flat;
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
