// Adding sound processes:
//
// You can add your own sound processes by making a codefile
// with an Ndef and the parameter ranges it needs;
// NTMI knows how to tie it into the system when you
// put that file into "~/NTMI/POOL/2_process/".
/*
Ndef(\abc).gui;
*/

// Here is a very simple example:
// define parameter ranges first
Ndef(\abc).addSpec (\pulsefreq, [20, 2000, \exp]); //
Ndef(\abc).addSpec (\modRate, [0.2, 20, \exp]); //
Ndef(\abc).addSpec (\fmodDepth, [0, 12, \amp]); //
Ndef(\abc).addSpec (\wmodDepth, [0, 1, \amp]); //
Ndef(\abc).addSpec (\passprob, [0.04, 1, \exp]); //
Ndef(\abc).addSpec (\pan, \pan); // range -1, 1

// then the sound process as an Ndef:
// by convention, the first parameter must be amp!
Ndef(\abc, { |amp = 0.25,
	pulsefreq = 60, modRate = 10, fmodDepth, wmodDepth,
	passprob = 0.25|
	// sound design here
	var snd = Pulse.ar(
		pulsefreq.lag(0.3)
		* LFDNoise3.kr(modRate!2, fmodDepth).midiratio,
		LFDNoise3.kr(modRate!2),
	);
	var passAmp = Latch.ar(CoinGate.ar(passprob, snd), snd);
	snd * passAmp * amp;
});

