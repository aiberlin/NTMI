q = q ?? {()};

Ndef(\robTron).ar(q.numChans);

// Halo stuff! used in Korg Nanoktl
Ndef(\robTron).addHalo(\scene, 0);
Ndef(\robTron).addHalo(\myRandSeed, 0);
Ndef(\robTron).addHalo(\s2Toggle, 0);

(
Ndef(\robTron).addSpec(\sub, [1/5, 5, \exp]);
Ndef(\robTron).addSpec(\sub2, [1/5, 5, \exp]);
Ndef(\robTron).addSpec(\pw1, [0.01, 0.99, \lin]);
Ndef(\robTron).addSpec(\pw2, [0.01, 0.99, \lin]);
Ndef(\robTron).addSpec(\pw3, [0.01, 0.99, \lin]);
Ndef(\robTron).addSpec(\maxScale, [5, 10000, \exp, 0.1]);
Ndef(\robTron).addSpec(\minScale, [0.1, 1000, \exp, 0.1]);
Ndef(\robTron).addSpec(\balAnce, [ 0, 2]);
Ndef(\robTron).addSpec(\s2, [0, 1.49,\linear, 1]);	// jus' one step!
Ndef(\robTron).addSpec(\robLag, [0, 5, 17]);
[\a, \b, \c, \d, \e, \f, \g, \h, \i, \q].do({ |sy|
	Ndef(\robTron).addSpec( sy, \unipolar.asSpec);
});
[\c_1a, \c_2b, \c_3c, \c_4d, \c_5e, \c_6f, \c_7g, \c_8h, \c_8i].do({ |sy|
	Ndef(\robTron).addSpec( sy, \unipolar.asSpec);
});



);

(
Ndef(\robTron).source =  {
	arg  amp=0, c_1a=0.5, c_2b=0.5, c_3c=0.5, c_4d=0.5,
	c_5e=0.5, c_6f=0.5, c_7g=0.5, c_8h=0.5,  c_8i=0.5,
	minScale=0.1,  maxScale=5000, sub=1, sub2=1, balAnce=2, s2=0,
	pw1=0.5, pw2=0.5, pw3=1, robLag=0.002;


	var trig, index, samp, bitshift=[0,0], numReadHeads = 4, ef, gh,
	x, y, z, s, r, t, u, w, ef_freq, tri, fb, xor, s2sig,
	outFLT, out, out_freq, stOut, localin, gh_freq;
	var wiiNAxLim, wiiAxLim, wiiNJoy, buf ;
	var a, b, c, d, e, f, g, h, rampsig, trigt, latcht, slope, dir, timet;

	buf = LocalBuf.newFrom( 0! (numReadHeads+1) );

	maxScale = maxScale.lag2(robLag*5);

	// first scale all in arg sigs;
	#e, g = LinExp.kr([ c_5e, c_7g], 0, 1, minScale, maxScale);

	# a, b = LinExp.kr([c_1a, c_2b], 0, 1, 20, 13000);
	# c, d =  LinLin.kr([c_3c, c_4d], 0, 1, 0, 12*8);

	#f, h = ([c_6f, c_8h ]).lag(robLag).cubed; // just curve ..
	i = LinExp.kr(c_8i, 0, 1,  minScale, maxScale).lag(robLag)-0.1;

	s2 = s2.clip(0.0, 1);
	#pw1, pw2 = [pw1, pw2].lag(robLag+1).clip(0.001, 1-0.001);
	pw3 = pw3.lag(robLag);

	localin = LocalIn.ar(1);
	fb = LinExp.ar(localin, 0, 1, 0.07,  25000);
	//		fb = LinExp.ar(localin, 0, 1, minScale, maxScale);

	// 2 inputs to ef freq: f + e
	ef_freq = (((fb  * f) + e ) * sub2).fold(0.1, 19500);
	ef = trig = LFPulse.ar(ef_freq, 0, pw1);
	tri = VarSaw.ar(ef_freq, 0, pw3, 0.5, 0.5);

	// 4 inputs to gh freq : g, fb*h, tri*i, ant*s3
	gh_freq =
	(i * tri)
	+ (fb*h)
	+ g
	* sub;
	gh = samp = LFPulse.ar(
		gh_freq, 0, pw2
	);
	// 		Poll.kr(Impulse.kr(10), ef_freq, \ef________________Freq);
	xor = (ef + gh) % 2;  // xor sig

	s2sig = (s2.madd([1, -1], [0, 1])
		* [xor, gh]
	).sum;

	trigt = HPZ1.ar(s2sig).abs;
	slope = Slope.ar(s2sig.lag(1/[1900, 900])).madd(1, 0.00001);
	timet = Timer.ar(trigt);
	latcht = (Latch.ar(trigt, slope).sign - 0.1);

	rampsig = Phasor.ar(trigt, latcht* 0.5/timet/SampleRate.ir, -1, 1, 0);
	////////SHIFTER !!!
	index = Stepper.ar(trig, 0, 0, numReadHeads);
	w = BufWr.ar(samp, buf, index);

	//	stereo from here!
	outFLT = 2.collect({ |iindex|
		bitshift[iindex] = (
			Index.ar( buf, (index - ((iindex+1*2) + (0..numReadHeads-1) )% (numReadHeads+1)) )
			* (2** (1..(numReadHeads)).neg )
		).sum;


		if(iindex==0){    // write back only one chan!
			LocalOut.ar(bitshift[iindex] );
		};
		// 4 - 5 inputs to out Fr:
		out_freq =
		(
			( bitshift[iindex] * d * [0,1] )
			+ ((tri * 2 - 1) * c * [1,0])
		). midiratio *
		[a, b];

		out_freq = out_freq.fold(20, 15000).clip(20, 15000);


		LPF.ar(
			s2sig,
			out_freq,
			[1, -1]
		).sum;

	});
	outFLT = Limiter.ar(outFLT);
	stOut = SelectX.ar(balAnce.lag(0.3), [rampsig, s2sig, outFLT, rampsig]) * amp;
	Sanitize.ar(
		stOut.collect{|si, i|
			PanAz.ar(q.numChans, si, SinOsc.kr(Rand(0.1, 0.2)*0.33, 0, Rand(1, 2)).round(LFNoise1.kr(0.1).exprange(0.001, 0.5).lag(0.1)), amp)
		}.sum
	);
}
);


/*fork {
0.5.wait;
Ndef(\robTron).supplementNodeMap;
0.5.wait;
Ndef(\robTron).play(vol: 0);
0.2.wait;
Ndef(\robTron).fadeTime = 3;
};*/
//////////////////////////////////////////////////////////////////////



Ndef(\robTron).addHalo(\reloadFunc, {
	"re-building ALL robTr !!!".postln;
	fork{
		var cachFunc;
		cachFunc = Ndef(\robTron).source;
		Ndef(\robTron).fadeTime = 0;
		0.02.wait;
		Ndef(\robTron).clear;
		0.1.wait;
		Ndef(\robTron).source = cachFunc;
		0.05.wait;
		Ndef(\robTron).supplementNodeMap;
		0.1.wait;
		Ndef(\robTron).play(vol: 0);
	}
});
//		Ndef(\robTron).gui;
//		{ Ndef(\robTron).getHalo(\reloadFunc).value; }.defer(1);
// "\n\nrobtron loaded\n".postln;
