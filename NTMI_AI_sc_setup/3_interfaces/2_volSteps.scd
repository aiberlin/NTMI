

MFdef(\mainVolStep).add(\step, { |inc = 0|
	// for fast turns, accelerate changes:
	// 0.0 is linear, step1 -> 1, step 2 -> 2 etc
	// 1.0 is quadratic, step1 -> 1, step 2 -> 4 etc
	var acceleration = inc.abs ** 1.0;
	"mainVol % by %\n".postf([\down, \up].wrapAt(inc.clip(0, 1)), inc);
	RelSet(MainFX(s).proxy, \mainVol, inc * acceleration * 0.01);
});

MFdef(\ndefVolStep).add(\step, { |ndef, step = 1|
	var acceleration = step.abs ** 1.0;
	var stepsize = 0.01; // 100 steps from 0 to 1
	var ampspec = \amp.asSpec;
	"% ndefVolStep %\n".postf(ndef, step);
	ndef.vol = ampspec.map(ampspec.unmap(ndef.vol) + (step * acceleration * stepsize))
});
