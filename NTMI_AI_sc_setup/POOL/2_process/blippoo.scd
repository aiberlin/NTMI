(
//q = q ? ();

// parameters (a mix of the first blippoo box as documented in the article by Rob Hordijk and the one Richard Scott has)
//Ndef(\blippoo).ar(q.numChans);
Ndef(\blippoo).addSpec(\freqOscA, [0.1, 20000, 'exp', 0, 440, " Hz"]);
Ndef(\blippoo).addSpec(\freqOscB, [0.1, 20000, 'exp', 0, 440, " Hz"]);
Ndef(\blippoo).addSpec(\fm_b_a, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_a_b, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_r_a, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_r_b, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_sah_a, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_sah_b, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\freqPeak1, [20, 20000, 'exp', 0, 440, " Hz"]);
Ndef(\blippoo).addSpec(\freqPeak2, [20, 20000, 'exp', 0, 440, " Hz"]);
Ndef(\blippoo).addSpec(\fm_r_peak1, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_r_peak2, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\fm_sah_peak, [0, 5000, 10, 0, 0, " Hz"]);
Ndef(\blippoo).addSpec(\resonance, [0.001, 2, 'exp', 0, 0.707, ""]);


//ControlSpec.specs[\resonance] = ControlSpec.specs[\rq].copy;


~rungler = {arg clock,sig; // this is the rumbler as described for the blippoo box
	var buffer = LocalBuf(8);// i am sure it could be implemented without buffer
	var pos = Stepper.ar(clock,0,0,7,1);
	var w = BufWr.ar(sig,buffer,pos);
	var r1 = BufRd.ar(1,buffer,(pos + 5)%8,0,0)>0;
	var r2 = BufRd.ar(1,buffer,(pos + 6)%8,0,0)>0;
	var r3 = BufRd.ar(1,buffer,(pos + 7)%8,0,0)>0;
	(((r1<<0) + (r2<<1) + (r3<<2))/7).lag(1/10000);
};

~twinpeaks = {arg in,f1,f2,r1,r2; // this is the twin peaks filter as described for the blippoo box but without the distortion (unfortunately)
	var l1 = RLPF.ar(in     ,f1.fold(20,20000).lag(0.05),r1);//lag is necessary to make sure the filter stays stable
	var l2 = RLPF.ar(in * -1,f2.fold(20,20000).lag(0.05),r2);
	l1 + l2;
};

Ndef(\blippoo,{|
	amp = 0,
	freqOscA = 10.46, //frequency oscilator a
	freqOscB = 0.32, //frequency oscilator b
	fm_b_a = 10.02, //fm oscilator b -> oscilator a
	fm_a_b = 2.81, //fm oscilator a -> oscilator b
	fm_r_a = 160.2, //fm rungler2 -> oscilator a
	fm_r_b = 16.27, //fm runglefreqOscA -> oscilator b
	fm_sah_a = 6.14, //fm SampleAndHold -> oscilator a
	fm_sah_b = 6.14, //fm SampleAndHold -> oscilator a

	freqPeak1 = 231.4, //freqency filter 1
	freqPeak2 = 895, //frequency filter 2
	fm_r_peak1 = 1000, //fm rungler1 -> filter 1
	fm_r_peak2 = 3000, //fm rungler2 -> filter 2
	// fm_r_peak = 94.31, //fm rungler2 -> filter 2
	fm_sah_peak = 272.1, //fm rungler2 -> filter 2
	// fm_sah_1 = 10, //fm SampleAndHold -> filter 1
	// fm_sah_2 = 10, //fm SampleAndHold -> filter 2
	resonance = 0.06 //filter resonance
	|

	var fb = LocalIn.ar(5);
	var rfreqOscA = freqOscA + LFNoise2.ar(freqOscA.max(10)/10,freqOscA.max(10)/1000);//add a bit randomness to the frequencies
	var rfreqOscB = freqOscB + LFNoise2.ar(freqOscB.max(10)/10,freqOscB.max(10)/1000);
	var tri1 = LFTri.ar((rfreqOscA + (fb[1] * fm_b_a) + (fb[2] * fm_r_a) + (fb[4] * fm_sah_a)).fold(0,20000));
	var tri2 = LFTri.ar((rfreqOscB + (fb[0] * fm_a_b) + (fb[3] * fm_r_b) + (fb[4] * fm_sah_b)).fold(0,20000));
	var puls1 = tri1>Delay1.ar(tri1);
	var puls2 = tri2>Delay1.ar(tri2);
	var sah = Latch.ar(tri1,puls2).lag(1/10000);
	var rungler1 = ~rungler.(puls1,puls2);
	var rungler2 = ~rungler.(puls2,puls1);
	var rung = rungler1 + rungler2;
	var comparator = ((tri1<tri2)-0.5).lag3ud(1/10000,1/5000);
	var pf1 = (freqPeak1 + (sah * fm_sah_peak * -1) + (rung * fm_r_peak1)).abs;
	var pf2 = (freqPeak2 + (sah * fm_sah_peak) + (rung * fm_r_peak2)).abs;
	var sig = ~twinpeaks.(comparator,pf1,pf2,resonance,resonance);
	var fbout = LocalOut.ar([tri1,tri2,rungler1,rungler2,sah]);

	var monoOut = Limiter.ar(Sanitize.ar(sig * 0.05)) * amp;

	q.numChans.collect {
		DelayL.ar( monoOut, 0.03, LFDNoise3.kr(0.3).range(0.0, 0.03))
	};

});

Ndef(\blippoo);


// Ndef(\blippoo).clear;

// Ndef(\blippoo).lag(*Ndef(\blippoo).controlKeys.collect ([_, 0.5]).flat);

/*
Ndef('blippoo').set('fm_sah_b', 32.584637770027, 'freqPeak1', 115.59385768307, 'fm_r_peak1', 1022.2025597648, 'freqOscB', 22.699345303073, 'freqOscA', 3.9693859855577, 'fm_r_a', 6.4822052062949, 'freqPeak2', 802.05582789904, 'resonance', 0.053593355607996, 'fm_r_b', 55.467640210437, 'fm_sah_peak', 187.8431927844, 'fm_b_a', 0.0, 'fm_sah_a', 4.1668212367655, 'fm_r_peak2', 669.35696176669, 'fm_a_b', 0.0).gui;
*/
)