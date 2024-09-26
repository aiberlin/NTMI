/*

Coding dojo

06.11.2023

- Implement Pulsar Synthesis as an Ndef
- parameters:
+ fundamental frequency
+ formant frequency
+ multiple envelope shapes
+ multiple formants
+ panning and amplitude control

+ Implement NdefPreset for our Ndef

- make our Ndef NTMI-ready

*/

// create a buffer and fill it with some sine waves
(
~pulsarDojoBuffer = Buffer.alloc(s, 2048, 1);
~pulsarDojoBuffer.loadCollection(Signal.sineFill(2048, [1], [0]));
/*
~pulsarDojoBuffer.plot;
*/
);

// define parameter ranges
(
Ndef(\pulsardojo).addSpec(\fundfreq, [1, 1000, \exp]);
Ndef(\pulsardojo).addSpec(\amp, \amp);
Ndef(\pulsardojo).addSpec(\formfreq1, [20, 20000, \exp]);
Ndef(\pulsardojo).addSpec(\curve1, [-10, 10, \lin]);
Ndef(\pulsardojo).addSpec(\amp1, \amp);
Ndef(\pulsardojo).addSpec(\pan1, \pan);
Ndef(\pulsardojo).addSpec(\formfreq2, [20, 20000, \exp]);
Ndef(\pulsardojo).addSpec(\curve2, [-10, 10, \lin]);
Ndef(\pulsardojo).addSpec(\amp2, \amp);
Ndef(\pulsardojo).addSpec(\pan2, \pan);
Ndef(\pulsardojo).addSpec(\formfreq3, [20, 20000, \exp]);
Ndef(\pulsardojo).addSpec(\curve3, [-10, 10, \lin]);
Ndef(\pulsardojo).addSpec(\amp3, \amp);
Ndef(\pulsardojo).addSpec(\pan3, \pan);
Ndef(\pulsardojo).addSpec(\modamount, [0,10]);
Ndef(\pulsardojo).addSpec(\delay1, [0,0.2]);
Ndef(\pulsardojo).addSpec(\delay2, [0,0.2]);
Ndef(\pulsardojo).addSpec(\delay3, [0,0.2]);
Ndef(\pulsardojo).addSpec(\wave, [0,1]);
Ndef(\pulsardojo).addSpec(\buffreq, [0.1,8]);


// make an Ndef that does pulsar synthesis
(
// amp has to be first for NTMI
Ndef(\pulsardojo, { |amp = 1,
	fundfreq = 10,
	formfreq1 = 100, curve1= -4, pan1 = 0, amp1= 1, delay1=0,
	formfreq2 = 100, curve2= -4, pan2 = 0, amp2= 1, delay2=0,
	formfreq3 = 100, curve3= -4, pan3 = 0, amp3= 2, delay3=0,
	modamount=0
	|
	var trig, pulseReader, bufferOutput, shapes, envelope, unpanned, snd, waves, frq;
	var formfreqs = [formfreq1,formfreq2,formfreq3];
	var curves = [curve1, curve2, curve3];
	var pans = [pan1, pan2, pan3];
	var amps = [amp1, amp2, amp3];
	var fb = LocalIn.ar(3);
	var pulseDur;
	//var formfreqsfb = formfreqs * (1 + ((fb * modamount)));
	pulseDur = (1/(formfreqs * (1+(fb * modamount))).clip(fundfreq,20000)) ;

	// generate a trigger signal for the pulsar waveform playback
	trig = Impulse.ar(fundfreq);
	pulseReader = EnvGen.ar(Env([0, 1, 0], [pulseDur, 0]), trig);

	// Envelope for the waveform
	envelope = EnvGen.ar(Env.perc(0, pulseDur, curve: curves), trig);

	bufferOutput = BufRd.ar(1, ~pulsarDojoBuffer,
		pulseReader * BufFrames.ir(~pulsarDojoBuffer),
		0);
	snd = bufferOutput * envelope;
	snd = DelayC.ar(snd, 0.2, [delay1, delay2, delay3].lag(0.05));

	LocalOut.ar(snd);
	//BufWr.ar(DelayC.ar(snd.sum.tanh, 2, 1) + SinOsc.ar(100), ~pulsarDojoBuffer, pulseReader[0] * BufFrames.ir(~pulsarDojoBuffer));
	//BufWr.ar((DPW3Tri.ar(8, 0.5) + DelayC.ar(snd.sum.tanh, 2, 0.2)), ~pulsarDojoBuffer, LFSaw.ar(8).range(0,1) * BufFrames.ir(~pulsarDojoBuffer));
	frq = 8 * \buffreq.kr(1);
	waves = [SinOsc.ar(frq), DPW3Tri.ar(frq), PulseDPW.ar(frq), LFNoise2.ar(frq * frq)];
	BufWr.ar((SelectX.ar(\wave.kr(0) * waves.size, waves) + (snd.sum/2) / 2).tanh , ~pulsarDojoBuffer, LFSaw.ar(8).range(0,1) * BufFrames.ir(~pulsarDojoBuffer));
	snd = Mix.ar(PanAz.ar(q.numChans, snd, pans, amps, 1.5));
	//snd = Mix.ar(Pan2.ar(snd, pans, amps));
	LeakDC.ar(snd * amp);
});
);
);

// NTMI compatibility - when you run the whole file,
// build Ndef once, then end it on startup
fork { 0.3.wait; Ndef(\pulsardojo).end };


/*l = ~pulsarDojoBuffer.plot;
Plotter
l.value = [0,1,0,60,8]
l.specs = [[-0,1]]
Tdef(\upd, { loop { (1/20).wait; ~pulsarDojoBuffer.getn(0, ~pulsarDojoBuffer.numFrames, {|array| defer { l.value = array; l.specs = [[-1,1].asSpec] }  })  } }).play
l.refresh*/
/* Preset tests:

p = NdefPreset(Ndef(\pulsardojo));
NdefPresetGui(p, 20);

p.setRand(1.0)
*/
