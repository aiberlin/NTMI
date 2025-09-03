
MFdef(\ndefVolStep).add(\step, { |ndef, step = 1|
	var acceleration = step.abs ** 1.0;
	var stepsize = 0.01; // 100 steps from 0 to 1
	var ampspec = \amp.asSpec;
	"% ndefVolStep %\n".postf(ndef, step);
	ndef.vol = ampspec.map(ampspec.unmap(ndef.vol) + (step * acceleration * stepsize))
});
