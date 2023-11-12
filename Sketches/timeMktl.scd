/// measuring lastUpdateTime from MKtls,
/// to display which interfaces were recently active
~time = ();
~time.actives = [ MKtl(\ntmi),  MKtl(\uc4),  MKtl(\ferrari) ];
~time.times = ();
~time.spec = [1000, 1, \exp].asSpec;
~time.actives.do { |mk| ~time.times.addSpec(mk.name, ~time.spec) };

~time.egui = EnvirGui(~time.times);

~time.times.getSpec

~time.skip.stop.free;
~time.skip = SkipJack({
	~time.actives.do { |mk|
		~time.times.put(mk.name, mk.timeSinceLast)
	}
});
~time.skip.dt = 0.5;

MKtl(\ntmi).elAt(\battery).action.cs;

l = List.new(1024);
MKtl(\ntmi).elAt(\battery).action = { |el|
	var val = el.deviceValue;
	// l.add(val);
	// val.postln;
	// if (val > 0) { val.postln };
};

l.postcs;