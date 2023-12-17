

// switch modes - analog in vs. IMU /// touch vs move mode
// NTMI.nufo.modes = [\full, \move, \touch, \binary, \off];
/*
NTMI.nufo.setModeIndex(100.rand)
NTMI.nufo[\mode]
*/

NTMI.nufo.modes = [\full, \touch, \binary]; //
NTMI.nufo.modeIndex = 0;
NTMI.nufo.mode = { NTMI.nufo.modes.wrapAt(NTMI.nufo.modeIndex) };


NTMI.nufo.setModeIndex = { |dict, modeIndex = 0|
	if (NTMI.nufo.modeIndex != modeIndex) {
		NTMI.nufo.modeIndex = modeIndex % NTMI.nufo.modes.size;
		"\n******* NEW MODE: % - i: % *****\n".postf(NTMI.nufo.mode, NTMI.nufo.modeIndex);
		(
			move:  { NTMI.nufo.moveON;  NTMI.nufo.touchOFF; NTMI.nufo.binOFF; },
			touch: { NTMI.nufo.moveOFF; NTMI.nufo.touchON; NTMI.nufo.binOFF; },
			full:  { NTMI.nufo.moveON;  NTMI.nufo.touchON; NTMI.nufo.binOFF; },
			binary: { NTMI.nufo.moveOFF;  NTMI.nufo.touchOFF; NTMI.nufo.binON; },
			off: { NTMI.nufo.moveOFF;  NTMI.nufo.touchOFF; NTMI.nufo.binOFF; },
		)[NTMI.nufo.mode].value;

		try { NTMI.nufo.sendNufoMode };
	};
};

NTMI.nufo.modeStep = { |dict, inc = 1|
	inc = inc ?? { NTMI.nufo.modes.size.rand };
	NTMI.nufo.setModeIndex(NTMI.nufo.modeIndex + inc);
};

// show modes as colors:
// green = both, red = move, blue = touch, black = off

NTMI.nufo.sendNufoMode = {
	var msg = [
		[ 0, 1, 0 ], // green is full
		[ 1, 0, 0 ], // red is touch
		[ 0, 0, 1 ], // [ blue is move ]
		[ 0, 0, 0 ]  // [ black is off ]
	].clipAt(NTMI.nufo.modeIndex);
	// send 3 times to make sure it arrives
	fork { 3.do {
		0.02.wait;
		try {
			MKtl(\nUFO).device.source.sendMsg("/ntmi/ledCtl/back", 7, *msg.keep(3));
		}
	} };
};

/////////// add funcs to inphMode switching so NTMI can do it /////////

NTMI.nufo.touchON = {
	"nUFO - touchON".postln;
	MFdef(\capsToInph).enable(\set);
	NTMI.slots.nowPlaying.do { |obj|
		if (NTMI.inph.decoupled.includes(obj.key).not) {
			NTMI.inph.couple(obj)
		}
	}
};

NTMI.nufo.touchOFF =  {
	"nUFO - touchOFF".postln;
	NTMI.slots.nowPlaying.do { |nd| NTMI.inphlux.action.disable(nd.key) };
	MFdef(\capsToInph).disable(\set);
	NTMI.inphlux.set(*NTMI.inphlux.getHalo(\padNames).collect([_, 0]).flat);
};

NTMI.nufo.moveON =  {
	"nUFO - moveON".postln;
	MFdef(\nUFOImuFunc).enable(\set);
	NTMI.slots.nowPlaying.do { |obj|
		if (NTMI.inph.decoupled.includes(obj.key).not) {
			NTMI.inph.couple(obj);
		}
	}
};

NTMI.nufo.moveOFF =  {
	"nUFO - moveOFF".postln;
	MFdef(\nUFOImuFunc).disable(\set);
	/////// pads set inphlux in unipolar, 0-1 range!
	// NTMI.inphlux.set(*NTMI.inphlux.getHalo(\imuNames).collect([_, 0]).flat);
};

NTMI.nufo.binON =  {
	"nUFO - binON".postln;
	MFdef(\capsToInph).enable(\binKey);
	// NTMI.slots.nowPlaying.do { |obj|
	// 	NTMI.inph.decouple(obj)
	// };
};

NTMI.nufo.binOFF =  {
	"nUFO - binOFF".postln;
	MFdef(\capsToInph).disable(\binKey);
};
