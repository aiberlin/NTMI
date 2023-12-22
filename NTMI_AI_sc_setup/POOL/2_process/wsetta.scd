/*

*** Create a WavesetsEvent instrument for NTMI, based on:
// wse / Xstrument style // hh, spring 2021

// install WavesetsEvent if needed
if (\WavesetsEvent.asClass.isNil) {
Quarks.install("WavesetsEvent");
thisProcess.recompile;
};


Tdef(\wsetta).gui(16);
Ndef(\wsetta).gui;

// NTMI.wse.sfdir.openOS;

NTMI.wse.sfdir = NTMI.dir.user +/+ "soundfiles/examples";
SoundFile.collect(NTMI.wse.sfdir +/+ "*");

// todo:
- if keep = true, keep earlier wavesets around
- simple GUI  to load more samples from
Butz.add(\wsetta, {


});

SoundFile.collect(NTMI.wse.sfdir +/+ "*");
*/

// init
(
WavesetsEvent.prepareSynthDefs;

// a dict for all things wavesetsevent
NTMI.wse = NTMI.wse ? ();

/////// default soundfiles dir / unless overwritten
NTMI.wse.sfdir = NTMI.wse.sfdir ?? { NTMI.dir.user +/+ "soundfiles/examples" };

// tweak for your machine, so very fast overlapped
// wavesets dont bring it down:
NTMI.wse.minWaitDur = NTMI.wse.minWaitDur ? 0.001;

NTMI.wse.loadWSEs = { |dict, dir, add = false|
	fork {
		var t0 = Main.elapsedTime;
		NTMI.wse.sfdir = dir ? NTMI.wse.sfdir;
		NTMI.wse.soundfiles = SoundFile.collect(NTMI.wse.sfdir +/+ "*");
		"... analysing % files for WavesetsEvent ...\n".postf(NTMI.wse.soundfiles.size);

		while { s.serverRunning.not } { 0.03.wait };
		NTMI.wse.wses = NTMI.wse.soundfiles.collect { |file|
			var wse = WavesetsEvent.read(file.path);
			try { s.sync; 0.1.wait; };
			wse;
		};
		"... ALL % WavesetsEvents loaded in % secs.\n\n".postf(
			NTMI.wse.soundfiles.size, Main.elapsedTime - t0);
	};
};

// Wsetta has extra gui -
if (NTMI.hasGui) {
	// this must happen after Butz was done - see GUIs/wsetta.scd
	// Butz.add(\wsetta, { WinBounds.showOrMake(\wsetta) });
	WinBounds.addMake(\wsetta, {
		// "~/src/aiberlin/NTMI/NTMI_AI_sc_setup/POOL/2_process/wsetta.scd".openOS;

		NTMI.wse.win = \Window.asClass.new("wsetta", Rect.aboutPoint(Window.screenBounds.center, 200, 150)).front;
		NTMI.wse.win.view.addFlowLayout;
		\Button.asClass.new(NTMI.wse.win, 100@30).states_([["new files"]]);
		\TdefGui.asClass.new(Tdef('wsetta'), 3, NTMI.wse.win);
		\NdefGui.asClass.new(Ndef('wsetta'), 12, NTMI.wse.win);

		NTMI.wse.win
	});
};

// load the default here:
NTMI.wse.loadWSEs(NTMI.wse.sfdir);

// and call NTMI.wse.loadWSEs again later to switch buffers,
// and to reload afer a server reboot:
ServerBoot.add({ NTMI.wse.loadWSEs }, s);

);



/*
General plan:
use an Ndef and Tdef combo, same names, same params

list of params
*** non-stored:
\wse_index - which wavesetsevent/file/buffer to choose
\wse_name - name of the assoc. soundfile
\pos - self moving, index of next waveset to choose
\amp - make this amp in ndef

*** to use in preset - maybe these are in Ndef nodemap only?
num: how many wavesets to play
repeats: how many times to repeat the selected wavesets
amp: scale the amplitude of the original sound
pan: stereo panorama position
wsamp: normalize the amplitude to that value
rate: playback speed of the audio file
rate2: end playback speed of the audio file (if used, will create a linear glisson sweep)

////// unused, but present in WSE:
// start: where to start playing
// startTime: where to start in the file - will be rounded to the next waveset (if given, overrides start)
// end: up to which waveset to play (if given, overrides num)
// endTime: where to end in the file - will be rounded to the next waveset (if given, overrides start)

questions:
how much automatic variation?
- try 0 variation,
- random or varation on everything

*/



(
// non-storable params, remain in Tdef only:
// which waveset by index
Tdef(\wsetta).set(\wse_index, 0);
// show path on tdefgui
Tdef(\wsetta).set(\wse_path, '?');
// running wavesets index
Tdef(\wsetta).set(\pos, 0);

Tdef(\wsetta).addSpec(\wse_index, [0, 10, \lin, 1]);
Tdef(\wsetta).addSpec(\pos, [0, 10000, 0, 1]);
);

(
//////// get these params from Ndef:

Ndef(\wsetta).clear;
Ndef(\wsetta).ar(2);

// and a silent dummy sound source, which determines the param names in order.
// could also put some post-processing in here:
Ndef(\wsetta, { |amp,
	num = 10, repeats = 1, progress = 10,
	legato = 1, rate = 1, rate2 = 1, pan = 0.5|
	Silent.ar(2);
});
// get default settings:
Ndef(\wsetta).supplementNodeMap;

Ndef(\wsetta).addSpec(\num, [1, 100, \exp, 1]);
Ndef(\wsetta).addSpec(\repeats, [1, 100, \exp, 1]);
Ndef(\wsetta).addSpec(\legato, [0.1, 10, \exp]);
Ndef(\wsetta).addSpec(\rate, [0.25, 4, \exp]);
Ndef(\wsetta).addSpec(\rate2, [0.25, 4, \exp]);
Ndef(\wsetta).addSpec(\legatoDev, [1, 10, \exp]);
Ndef(\wsetta).addSpec(\wsamp, \amp);

Ndef(\wsetta).addSpec(\progress, [-34, 34, 0, 1]);


// ndef source is the Tdef ...
Ndef(\wsetta).put(5, Tdef(\wsetta));

Ndef(\wsetta).end;
);

// simple, no random variation except pan
(
Tdef(\wsetta).quant_(0);
Tdef(\wsetta, {
	var myname = \wsetta;
	var myndef = Ndef(myname);
	var mymap = myndef.nodeMap;
	var mytdef = Tdef(myname);
	// why does { |ev| ... } not work here?
	// ugly workaround:
	var ev = mytdef.envir;

	var wse, prevwse;

	var posSpec = mytdef.getSpec(\pos);

	var remainDT = 0.05;

	mymap.postcs;

	"% runs ... \n".postf(mytdef);

	mytdef.getSpec(\wse_index).maxval_(NTMI.wse.wses.size);

	ev.pos = ev.pos ? 0;

	// NTMI.wse.wses.postln;

	inf.do { |i|
		var event;
		var soundDur, totalDur, remainWaitDur;
		/////// post steps and wait for debug
		// i.postln; 1.wait;

		/////// which wavesets? post if changed
		wse = NTMI.wse.wses.wrapAt((ev.wse_index ? 0).asInteger);
		if (wse.isNil) {
			"wsetta: no wavesets loaded in NTMI.wse.wses!".postln;
			1.wait;
		} {
			if (wse != prevwse) {
				"WSEtta switched:".postln;
				ev[\wse_path] = wse.buffer.path.basename.postcs;
				posSpec.maxval_(wse.size);
				prevwse = wse;
			};

			// // and make the event to play
			event = wse.asEvent((
				start: ev[\pos] % (wse.size - 1),
				num: mymap[\num],
				repeats: mymap[\repeats],
				legato: mymap[\legato],
				rate: mymap[\rate],
				rate2: mymap[\rate2],
				pan: mymap[\pan].rand2,
				wsamp: mymap[\amp] / mymap[\legato].max(1).sqrt,
				out: myndef.index
			));

			event.play;


			soundDur = event.sustain;
			// minimal safety wait when no waveset found
			totalDur = (event[\dur] ? 0.01 / event[\rate]);

			max(totalDur, NTMI.wse.minWaitDur).wait;

			ev.pos = ev.pos + mymap[\progress] % wse.size;

			///// sketch for faster updates:
			// // if legato is low, potentially long pauses:
			// // split waittime in small steps,
			// remainWaitDur = totalDur - soundDur;
			//
			// min(soundDur, totalDur).wait;
			// while { remainDur > 0 } {
			//  // update how fast remainDur should shrink!
			// 	remainDur = remainDur - remainDT;
			// 	0.1.wait;
			// };
			////// maybe better:
			////// do repeats by hand and update there
			////// if anything changed, do it there?
		}
	}
})
);

// return the Ndef!
Ndef(\wsetta);
