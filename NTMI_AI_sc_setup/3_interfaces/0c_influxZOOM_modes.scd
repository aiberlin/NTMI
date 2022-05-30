// q.zoom sets all the influx'es inScalers AND RandomOrbit's excursion from current state.

q.zoom = q.zoom?1;

// tune this for jitter on zoom pot on NTMI
Spec.add(\zoom, [0, 1, \lin, 0.025]);

q.setZoom = {|ev, val|
	val = \zoom.asSpec.constrain(val);
	// "global ZOOM f. RandomOrbits and Influxes: %\n".postf(val);
	q.zoom = val;

	q.inphlux.inScaler = q.zoom;
	"zoom: %\n".postf(q.zoom);
   // return value
	val
};
// increment / decrement
q.incZoom = {|ev, inc=0.1|
	q.setZoom((q.zoom + inc));
};

// switch modes - analog in vs. IMU /// touch vs move mode
// q.inph.modes = [\full, \move, \touch, \binary, \off];
q.inph.modes = [\full, \touch, \binary]; //
q.inph.modeIndex = 0;
q.inph.mode = { q.inph.modes.wrapAt(q.inph.modeIndex) };


/////// functions that switch the main modes components on/off:
// MFdef(\moveON).add(\info, { "move ON".postln });
// MFdef(\moveOFF).add(\info, { "move OFF".postln });
// MFdef(\touchON).add(\info, { "touch ON".postln });
// MFdef(\touchOFF).add(\info, { "touch OFF".postln });
// MFdef(\touchON).add(\info, { "binary ON".postln });
// MFdef(\touchOFF).add(\info, { "binary OFF".postln });


MFdef(\inphModeSetIndex).add(\set, { |modeIndex = 0|
	if (q.inph.modeIndex != modeIndex) {
		q.inph.modeIndex = modeIndex % q.inph.modes.size;
		"\n******* NEW MODE: % *****\n".postf(q.inph.mode);
		(
			move:  { MFdef(\moveON).value;  MFdef(\touchOFF).value; MFdef(\binOFF).value; },
			touch: { MFdef(\moveOFF).value; MFdef(\touchON).value; MFdef(\binOFF).value; },
			full:  { MFdef(\moveON).value;  MFdef(\touchON).value; MFdef(\binOFF).value; },
			binary: { MFdef(\moveOFF).value;  MFdef(\touchOFF).value; MFdef(\binON).value; },
			off: { MFdef(\moveOFF).value;  MFdef(\touchOFF).value; MFdef(\binOFF).value; },
		)[q.inph.mode].value;
	};
});

MFdef(\inphModeStep).add(\step, { |inc = 1|
	inc = inc ?? { 3.rand };
	MFdef(\inphModeSetIndex).value(q.inph.modeIndex + inc);
});