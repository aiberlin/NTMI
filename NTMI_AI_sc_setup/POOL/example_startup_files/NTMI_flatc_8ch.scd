/*** NTMI & flatcat setup ***

// test playing and recording to 8 channels:
- should be able to set 8 out chans
- should be able to play each slot in stereo on [0, 2, 4, 6]
- should record 8 chans for 20 mins


SkipJack {
	NTMI.ndefs.do { |nd, i|
		var moni = nd.monitor;
		if (moni.notNil) {
			var out = moni.out;
			if (out != (i * 2)) {
				moni.out_ (i*2)
			}
		};
	};
};

s.recChannels = 8;
s.record("~/Desktop/test8.wav")



// start oscar&xflux
NTMI.oscar.makeServer;
// activate flatcat simulation
defer ({ Tdef(\flatcatSim).stop.play }, 1);

// stop this tdef from unintended self-looping (happens sometimes)
Tdef(\allLEDs).clear;

// NetLib quark has this:
NetAddr.myIP
// nUFO NTMI network address is:
"169.254.1.2"
// close nUFO device when switching to flatcat
MKtl(\nUFO).closeDevice;

*****/

// s.options.device = "UMC404HD 192k";

NTMI.interfacesToLoad = [
	"uc4", "mu8",
	"ferrari",
	"xtm",
	"flatcat",
];

s.options.numOutputBusChannels;

NTMI.numChans = 8;

// Schedule loading the flatcat files
// after the full NTMI setup finishes:
NTMI.finalSetup = {

	"\n\n*** NTMI.finalSetup for AbsRel+flatcat: \n".postln;

	Butz(\NTMI).run(\InfluxMixer);
	Window.find(\InfluxMixer).moveTo(500, 700).front;

	// NTMI.tryLoadMKtl("kraken_modal*");

	Butz(\NTMI).remove(\miniNTMI);
	Butz(\NTMI).add(\flatcat, {
		defer {
			// load flatcat setup/connection file
			NTMI.tryLoadMKtl("flatcat/*flatcat*");
			NTMI.g.main.imuUV.drawFunc.add(\flatcat, NTMI.flatcat.drawFunc);
			// NTMI.g.main.imuUV.drawFunc.disable(\imuPad);
			NTMI.g.main.imuUV.animate_(true);
			NTMI.flatcat.zoom = 1.0;

			// Window.find(\flatcat).moveTo(500, 200).front;
		}
	});

	// autostart flatcat sim?
	defer ({ Tdef(\flatcatSim.postln).stop.play }, 5);
};

// now run NTMI setup, then flatcat
NTMI.run;

