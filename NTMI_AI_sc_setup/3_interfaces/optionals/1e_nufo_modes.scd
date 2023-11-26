

// switch modes - analog in vs. IMU /// touch vs move mode
// NTMI.osc.nUFO.modes = [\full, \move, \touch, \binary, \off];
/*
NTMI.osc.nUFO.setModeIndex(100.rand)

*/
NTMI.osc.nUFO.modes = [\full, \touch, \binary]; //
NTMI.osc.nUFO.modeIndex = 0;
NTMI.osc.nUFO.mode = { NTMI.osc.nUFO.modes.wrapAt(NTMI.osc.nUFO.modeIndex) };


NTMI.osc.nUFO.setModeIndex = { |dict, modeIndex = 0|
	if (NTMI.osc.nUFO.modeIndex != modeIndex) {
		NTMI.osc.nUFO.modeIndex = modeIndex % NTMI.osc.nUFO.modes.size;
		"\n******* NEW MODE: % - i: % *****\n".postf(NTMI.osc.nUFO.mode, NTMI.osc.nUFO.modeIndex);
		(
			move:  { NTMI.osc.nUFO.moveON;  NTMI.osc.nUFO.touchOFF; NTMI.osc.nUFO.binOFF; },
			touch: { NTMI.osc.nUFO.moveOFF; NTMI.osc.nUFO.touchON; NTMI.osc.nUFO.binOFF; },
			full:  { NTMI.osc.nUFO.moveON;  NTMI.osc.nUFO.touchON; NTMI.osc.nUFO.binOFF; },
			binary: { NTMI.osc.nUFO.moveOFF;  NTMI.osc.nUFO.touchOFF; NTMI.osc.nUFO.binON; },
			off: { NTMI.osc.nUFO.moveOFF;  NTMI.osc.nUFO.touchOFF; NTMI.osc.nUFO.binOFF; },
		)[NTMI.osc.nUFO.mode].value;

		try { NTMI.osc.sendNufoMode };
	};
};

NTMI.osc.nUFO.modeStep = { |dict, inc = 1|
	inc = inc ?? { NTMI.osc.nUFO.modes.size.rand };
	NTMI.osc.nUFO.setModeIndex(NTMI.osc.nUFO.modeIndex + inc);
};

NTMI.osc.sendNufoMode = {
	var msg = [
		[ 0, 1, 0 ], // green is full
		[ 1, 0, 0 ], // red is touch
		[ 0, 0, 1 ], // [ blue is move ]
		[ 0, 0, 0 ]  // [ black is off ]
	].clipAt(NTMI.osc.nUFO.modeIndex);
	// send 3 times to make sure it arrives
	fork { 3.do {
		0.02.wait;
		try {
			MKtl(\nUFO).device.source.sendMsg("/ntmi/ledCtl/back", 7, *msg.keep(3));
		}
	} };
};
