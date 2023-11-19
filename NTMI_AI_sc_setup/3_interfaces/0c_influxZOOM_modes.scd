// NTMI.zoom sets all the influx'es inScalers AND RandomOrbit's excursion from current state.

NTMI.zoom = NTMI.zoom?1;

// tune this for jitter on zoom pot on NTMI
Spec.add(\zoom, [0, 1, \lin, 0.025]);

NTMI.setZoom = {|ev, val|
	val = \zoom.asSpec.constrain(val);
	// "global ZOOM f. RandomOrbits and Influxes: %\n".postf(val);
	NTMI.zoom = val;

	NTMI.inphlux.inScaler = NTMI.zoom;
	"zoom: %\n".postf(NTMI.zoom);
   // return value
	val
};
// increment / decrement
NTMI.incZoom = {|ev, inc=0.1|
	NTMI.setZoom((NTMI.zoom + inc));
};

// switch modes - analog in vs. IMU /// touch vs move mode
// NTMI.inph.modes = [\full, \move, \touch, \binary, \off];
NTMI.inph.modes = [\full, \touch, \binary]; //
NTMI.inph.modeIndex = 0;
NTMI.inph.mode = { NTMI.inph.modes.wrapAt(NTMI.inph.modeIndex) };


/////// functions that switch the main modes components on/off:
// MFdef(\moveON).add(\info, { "move ON".postln });
// MFdef(\moveOFF).add(\info, { "move OFF".postln });
// MFdef(\touchON).add(\info, { "touch ON".postln });
// MFdef(\touchOFF).add(\info, { "touch OFF".postln });
// MFdef(\touchON).add(\info, { "binary ON".postln });
// MFdef(\touchOFF).add(\info, { "binary OFF".postln });


MFdef(\inphModeSetIndex).add(\set, { |modeIndex = 0|
	if (NTMI.inph.modeIndex != modeIndex) {
		NTMI.inph.modeIndex = modeIndex % NTMI.inph.modes.size;
		"\n******* NEW MODE: % *****\n".postf(NTMI.inph.mode);
		(
			move:  { MFdef(\moveON).value;  MFdef(\touchOFF).value; MFdef(\binOFF).value; },
			touch: { MFdef(\moveOFF).value; MFdef(\touchON).value; MFdef(\binOFF).value; },
			full:  { MFdef(\moveON).value;  MFdef(\touchON).value; MFdef(\binOFF).value; },
			binary: { MFdef(\moveOFF).value;  MFdef(\touchOFF).value; MFdef(\binON).value; },
			off: { MFdef(\moveOFF).value;  MFdef(\touchOFF).value; MFdef(\binOFF).value; },
		)[NTMI.inph.mode].value;
	};
});

MFdef(\inphModeStep).add(\step, { |inc = 1|
	inc = inc ?? { NTMI.inph.modes.size.rand };
	MFdef(\inphModeSetIndex).value(NTMI.inph.modeIndex + inc);
});