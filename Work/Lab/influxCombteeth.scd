
q.addCombTeeth = { |dict, ndef, influx|
	var controlKeys = ndef.controlKeys;
	var influxKeysDict = ();

	ndef.addHalo(\keysAll, controlKeys);
	ndef.addHalo(\influxKeysDict.postcs, influxKeysDict);
	controlKeys.do { |ckey, i|
		influxKeysDict.put(*[ckey, influx.outNames[i]].postcs);
	};

	ndef.addHalo(\keysOff, [\amp]);
	ndef.addHalo(\keysScram, controlKeys.scramble);
	ndef.addHalo(\keysPercent, 1.0);

	ndef.addHalo(\keysToGet, { |dict|
		var keysScram, numKeys;
		keysScram = dict[\keysScram];
		keysScram.removeAll(dict[\keysOff]);
		numKeys =  (dict[\keysPercent].clip(0, 1) * keysScram.size).round(1).asInteger;
		keysScram.keep(numKeys)
	});

	ndef.addHalo(\setFromInfluxTeeth, { |dict|
		var keysVals = dict.keysToGet.collect { |ckey, i|
			var infoutkey = dict[\influxKeysDict][ckey];
			var inflval = influx.outValDict[infoutkey];
			if (inflval.isNil) {
				[ckey, infoutkey, inflval].postcs;
				nil
			} {
				[ckey, inflval.biuni];
			};
		}.flat;

		ndef.setUni(*keysVals);
	});
};

q.addCombTeeth(Ndef(\robTron), q.inphlux);

Ndef(\robTron).controlKeys.size;
q.inphlux.outNames.size
q.inphlux.outValDict.size
q.inphlux.outNames.collect { |name| q.inphlux.outValDict[name] };



Ndef(\robTron).addHalo(\keysPercent, 0.33);
Ndef(\robTron).getHalo.keysToGet;
Ndef(\robTron).controlKeys.difference(Ndef(\robTron).getHalo.influxKeysDict.keys);
Ndef(\robTron).getHalo.setFromInfluxTeeth;

Ndef(\robTron).getHalo.influxKeysDict.size;

Ndef(\robTron).addHalo(\keysPercent, 0.51);
Ndef(\robTron).getHalo.keysToGet;

Ndef(\robTron).addHalo(\keysPercent, -123);
Ndef(\robTron).getHalo.keysToGet;

