// q.zoom sets all the influx'es inScalers AND RandomOrbit's excursion from current state.

q.zoom = q.zoom?1;

// tune this for jitter on zoom pot on NTMI
Spec.add(\zoom, [0, 1, \lin, 0.02]);

q.setZoom = {|ev, val|
	val = \zoom.asSpec.constrain(val);
	// "global ZOOM f. RandomOrbits and Influxes: %\n".postf(val);
	q.zoom = val;
	q.inphlux.inScaler = q.zoom;
   // return value
	val
};
// increment / decrement
q.incZoom = {|ev, inc=0.1|
	q.setZoom((q.zoom + inc));
};


// set it to poti on ana in 8 (it was 7, not worked)
MKtl(\xosc).elAt('inA').at(7).action.add(\setZoom, {|el|
	var val = el.value.clip(0.05, 1).round(0.05);
	if (val != q.zoom) {
		"zoom from xosc: %\n".postf(val);
		q.setZoom(val)
	};
});

