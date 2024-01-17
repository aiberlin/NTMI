

/*
// switch nUFO modes - touch pads, IMU, touch pads as binary

NTMI.nUFO.setModeIndex(100.rand)
NTMI.nUFO[\mode];

// the full choice of modes is:
NTMI.nUFO.modes = [
	\full,    // move/imu, touch/pads
	\move,    // only move/imu
	\touch,   // only touch/pads
	\binary,  // pads as binary preset-switching clavier
	\binMove, // pads as binary, plus move/imu best in setRel mode
	\off      // all
];

// choice of modes can be customized:
NTMI.nUFO.modes = [\full, \move, \touch, \binary, \off];

*/

// default choice of modes: [\full, \touch, \binary]

NTMI.nUFO.modes = NTMI.nUFO.modes ? [\full, \touch, \binary];

// switch colors to this dict later
NTMI.nUFO.modeColDict = (
	touch:   [ 1, 0, 0 ], // red is touch
	full:    [ 0, 1, 0 ], // green is full
//	move:    [ 0, 0, 1 ], // [ blue is move ]
	binary:  [ 0, 0, 1 ], // [ blue is binary ]
	binMove: [ 0, 1, 1 ], // [ cyan is binary+move ]
	off:	 [ 0, 0, 0 ]  // [ black is off ]
].clipAt(NTMI.nUFO.modeIndex);

NTMI.nUFO.modeIndex = 0;
NTMI.nUFO.mode = { NTMI.nUFO.modes.wrapAt(NTMI.nUFO.modeIndex) };


NTMI.nUFO.setModeIndex = { |dict, modeIndex = 0|
	if (NTMI.nUFO.modeIndex != modeIndex) {
		NTMI.nUFO.modeIndex = modeIndex % NTMI.nUFO.modes.size;
		"\n******* NEW MODE: % - i: % *****\n".postf(NTMI.nUFO.mode, NTMI.nUFO.modeIndex);
		(
			move:  { NTMI.nUFO.moveON;  NTMI.nUFO.touchOFF; NTMI.nUFO.binOFF; },
			touch: { NTMI.nUFO.moveOFF; NTMI.nUFO.touchON; NTMI.nUFO.binOFF; },
			full:  { NTMI.nUFO.moveON;  NTMI.nUFO.touchON; NTMI.nUFO.binOFF; },
			binary: { NTMI.nUFO.moveOFF;  NTMI.nUFO.touchOFF; NTMI.nUFO.binON; },
			binMove: { NTMI.nUFO.moveON;  NTMI.nUFO.touchOFF; NTMI.nUFO.binON; },
			off: { NTMI.nUFO.moveOFF;  NTMI.nUFO.touchOFF; NTMI.nUFO.binOFF; },
		)[NTMI.nUFO.mode].value;

		try { NTMI.nUFO.sendNufoMode };
	};
};

NTMI.nUFO.modeStep = { |dict, inc = 1|
	inc = inc ?? { NTMI.nUFO.modes.size.rand };
	NTMI.nUFO.setModeIndex(NTMI.nUFO.modeIndex + inc);
};

// show modes as colors:
// green = both, red = move, blue = touch, black = off
NTMI.nUFO.sendNufoMode = {
	var msg = [
		[ 0, 1, 0 ], // green is full
		[ 1, 0, 0 ], // red is touch
		[ 0, 0, 1 ], // [ blue is move ]
		[ 0, 0, 0 ]  // [ black is off ]
	].clipAt(NTMI.nUFO.modeIndex);
	// send 3 times to make sure it arrives
	fork { 3.do {
		0.02.wait;
		try {
			MKtl(\nUFO).device.source.sendMsg("/ntmi/ledCtl/back", 7, *msg.keep(3));
		}
	} };
};

/////////// add funcs to inphMode switching so NTMI can do it /////////

NTMI.nUFO.touchON = {
	"nUFO - touchON".postln;
	MFdef(\capsToInph).enable(\set);
	NTMI.slots.nowPlaying.do { |obj|
		if (NTMI.inph.decoupled.includes(obj.key).not) {
			NTMI.inph.couple(obj)
		}
	}
};

NTMI.nUFO.touchOFF =  {
	"nUFO - touchOFF".postln;
	NTMI.slots.nowPlaying.do { |nd| NTMI.inphlux.action.disable(nd.key) };
	MFdef(\capsToInph).disable(\set);
	NTMI.inphlux.set(*NTMI.inphlux.getHalo(\padNames).collect([_, 0]).flat);
};

NTMI.nUFO.moveON =  {
	"nUFO - moveON".postln;
	MFdef(\nUFOImuFunc).enable(\set);
	NTMI.slots.nowPlaying.do { |obj|
		if (NTMI.inph.decoupled.includes(obj.key).not) {
			NTMI.inph.couple(obj);
		}
	}
};

NTMI.nUFO.moveOFF =  {
	"nUFO - moveOFF".postln;
	MFdef(\nUFOImuFunc).disable(\set);
};

NTMI.nUFO.binON =  {
	"nUFO - binON".postln;
	MFdef(\capsToInph).enable(\binKey);
};

NTMI.nUFO.binOFF =  {
	"nUFO - binOFF".postln;
	MFdef(\capsToInph).disable(\binKey);
};
