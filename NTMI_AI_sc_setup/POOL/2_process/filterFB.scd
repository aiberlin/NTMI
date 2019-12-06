// feedback process, dhml 2014,
// from weight matrix example
// hh turned MC, 2019

q = q ?? ();

(
Ndef(\filterFB).addSpec(\freqA, [100, 1500, \exp]);
Ndef(\filterFB).addSpec(\freqB, [100, 1500, \exp]);
Ndef(\filterFB).addSpec(\loFreqA, [2, 40, \exp]);
Ndef(\filterFB).addSpec(\loFreqB, [2, 40, \exp]);
Ndef(\filterFB).addSpec(\filtfq, [80, 15000, \exp]);
Ndef(\filterFB).addSpec(\delaytime, [0, 0.5, \lin]);
Ndef(\filterFB).addSpec(\fbk, [0, 0.69, \amp]);
Ndef(\filterFB).addSpec(\direct, [0.001, 0.9, \amp]);
/*
Ndef(\filterFB, {
|amp=0, direct=0.05, freqA = 440, freqB = 586, loFreqA = 8.125, loFreqB = 13.193,
filtfq = 3429, delaytime = 0.05, fbk = 0.01|
var fbkIn = LocalIn.ar(1) * fbk;
var extraIn = q.liveInput.ar(1) * direct;

var osc = LFSaw.ar([freqA, freqB, loFreqA, loFreqB]).product;
var filt = RLPF.ar(osc, filtfq, 1/8);
var delay = DelayC.ar(filt + fbkIn + extraIn, 0.5, delaytime.lag(1.1));
var son = (filt + delay);
LocalOut.ar(delay);
son.clip2(1) * amp * (1-Dust.kr(1/10! q.numChans, 30).lag(0.3, 7)).clip(0,1);
});*/

Ndef(\filterFB, {
	|amp=0, direct=0.05, freqA = 440, freqB = 586, loFreqA = 8.125, loFreqB = 13.193,
	filtfq = 3429, delaytime = 0.05, fbk = 0.01|
	var fbkIn = LocalIn.ar(q.numChans) * fbk;
	var extraIn = q.liveInput.ar(1) * direct;

	var ouz = q.numChans.collect{|i|

		var osc = LFSaw.ar([freqA, freqB, loFreqA, loFreqB * ExpRand(0.9, 1.2)]).product;
		// var filt = MoogFF.ar(osc, filtfq, 3.5);
		var filt = RLPF.ar(osc, filtfq.lag2(0.2) * ([1,2,1.5]@@i), 1/8);
		var delay = DelayC.ar(Limiter.ar(filt + fbkIn.wrapAt(i+1) + extraIn, 0.99), 0.5, delaytime.lag(1.1));
		var son = (filt + delay);
		[son, delay]
	};
	LocalOut.ar(ouz.flop.last);
	ouz.flop.first.clip2(1) * amp //* (1-Dust.kr(1/10! q.numChans, 30).lag(0.3, 7)).clip(0,1);
});
);

fork { s.sync; 0.1.wait; Ndef(\filterFB).end };
Ndef(\filterFB);

