// q.zoom sets all the influx'es inScalers AND RandomOrbit's excursion from current state.

q.zoom = q.zoom?1;

q.setZoom = {|ev, val|
	val = val.clip(0.05, 1.0).round(0.05);
	// "global ZOOM f. RandomOrbits and Influxes: %\n".postf(val);
	q.zoom = val;
	// do external funcs here
	try{ q.prez.ezs.value = q.zoom };
	q.inphlux.inScaler = q.zoom;
   // return value
	val
};
// increment / decrement
q.incZoom = {|ev, inc=0.1|
	q.setZoom((q.zoom + inc));
};


// set it to poti on ana in 8 (it was 7, not worked)
x.elAt('inA').at(7).action.add(\setZoom, {|el|
	var val = el.value.clip(0.05, 1).round(0.05);
	if (val != q.zoom) {
		"zoom from xosc: %\n".postf(val);
		q.setZoom(val)
	};
});

