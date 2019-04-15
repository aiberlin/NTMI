q.inphlux.resetInvals;

fork {
	var infx = q.inphlux;
	var names = q.inphlux.getHalo.imuNames;
	~allOuts = (0.. 511).collect { |allCombos|
		var bits = allCombos.asInteger.asBinaryDigits(9);
		infx.set(*[names, bits.unibi].flop.flat);
		0.1.wait;
		infx.outValDict.asArray;
	};
	"done".postln;
};

~testa = ~allOuts.flop.collect(_.sort)[0];
~testa.plot;
~testa.tanh.plot;

q.inphlux.inScaler

~testa
~testa.bilin(0, -4, 4, 1, -4, 4, nil).plot;

[-4, -3, -2, -1, 0, 1, 2, 3, 4].bilin(0, -4, 4, 1, -4, 4, nil);

