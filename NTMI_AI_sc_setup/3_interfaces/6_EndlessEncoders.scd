/*** How to make MIDI encoders endless for relative use:

Rotary encoders are often in absolute mode, meaning they hit a max or min,
of 0 or 127 even though they can physically rotate endlessly.
When it is inconvenient to switch them to relative encoder mode in hardware, there are several alternatives:

1. Simple direct way to make sure there is a minimum step.

// basic way to calculate the change on the interface element:
MKtl(\x).elAt(\enc, 0).action = { |enc|
var step = enc.deviceValue - enc.prevDeviceValue;
// typically use this e.g. for influx relSet
MFdef(\relSetInf).value(step * 0.01, influxChan, zoom)
};

// now when the element is at minval 0 or maxval 127,
// and one keeps turning further, it sends 127 again, and
// enc.deviceValue - enc.prevDeviceValue becomes 0.
// But if we clip enc.prevDeviceValue to a smaller range,
// we always have a minimum step of 1 or -1,
// so we still get relative movement:

var step = enc.deviceValue - enc.prevDeviceValue.clip(1, 126);


2. NTMI.encDelta (see below) uses this approach for minimal delta values,
with changeable minimum step and option to clip step size.
This is simple and reliable.
*/

NTMI.encDelta = { |q, el, mindelta = 1, maxdelta|
	var val = el.deviceValue - el.prevDeviceValue.clip(mindelta, 127 - mindelta);
	if (maxdelta.isNumber) { val = val.clip2(maxdelta) };
	val;
};

/*
// this works fine with uc4 and likely everything
// that keeps sending 127 when hitting max:
MKtl(\uctest).free; MKtl(\uctest, "*uc4_pg").gui;
MKtl(\uctest).elAt(0, \kn).do { |enc|
	enc.action = {
		// solution 1, direct code:
		// var delta = enc.deviceValue - enc.prevDeviceValue.clip(1, 126);
		///// use the NTMI func:
		var delta = NTMI.encDelta(enc);
		"val: % - prev: % => delta %\n".postf(
			enc.deviceValue,
			enc.prevDeviceValue,
			delta
		);
		// use delta as relative step in vol, param, etc
	}
};

Option 3.
NTMI.resetOnMinMax resets to the center value when hitting 0 or 127,
so the rotation can continue in any direction from there.

NTMI.resetOnMinMax does not work reliably on every device,
as they react differntly to having their values reset,
so if you want to use that for for device, test it well!
*/

NTMI.resetOnMinMax = { |q, el, min = 0, max = 127, newmin = 64, newmax = 64, delay = 0.02|
	// reset if minval
	if (el.deviceValue <= min) {
		"% min reached, reset to %\n".postf(el, newmin);
		// set deviceValue twice so prevDeviceValue is also new.
		defer ({ el.deviceValue_(newmin).deviceValue_(newmin) }, delay)
	};
	// reset if maxval
	if (el.deviceValue >= max) {
		defer ({ el.deviceValue_(newmax).deviceValue_(newmax) }, delay)
	};
};


/*
// NTMI.resetOnMinMax does not work reliably on every device.
///// works mostly OK with uc4:
MKtl(\uctest).free; MKtl(\uctest, "*uc4_pg").gui;
MKtl(\uctest).elAt(0, \kn).do { |enc|
	enc.action = {
		var delta = enc.deviceValue - enc.prevDeviceValue;
		"val: % - prev: % => delta %\n".postf(
			enc.deviceValue,
			enc.prevDeviceValue,
			delta
		);
		NTMI.resetOnMinMax(enc);
	}
};

///// does not work reliably on en16
// the en16 gets confused whether its value is 127 or 64.
MKtl(\enTest).free; MKtl(\enTest, "*grid").gui;
MKtl(\enTest).elAt(\enc).do { |enc|
	enc.action = {
		var delta = enc.deviceValue - enc.prevDeviceValue;
		"val: % - prev: % => delta %\n".postf(
			enc.deviceValue,
			enc.prevDeviceValue,
			delta
		);
		NTMI.resetOnMinMax(el);
	}
};
*/


