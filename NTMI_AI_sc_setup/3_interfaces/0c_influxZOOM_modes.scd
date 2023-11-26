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

