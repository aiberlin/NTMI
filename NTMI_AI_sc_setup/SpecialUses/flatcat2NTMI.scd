/*
Flatcat is a robot pet made by jetpack cognition lab:
https://flatcat.berlin
it has three joints which sense the forces affecting them,
and decides on movements based on this connection to its environment.
In an experimental version of its code, it sends out an OSC message
with sensor data, planned motor control currents, and motor temperatures.
https://gitlab.com/jetpack-cognition-lab/flatcat_ux0/
https://gitlab.com/jetpack-cognition-lab/flatcat_ux0/-/tree/osc?ref_type=heads

This file receives flatcat data and maps them
to the NTMI setup by setting the influx inputs.

There are two ways to connect to the flatcat:
1. The flatcat has its own WiFi access point called flatcat00,
where 00 is replaced by the flatcat serial number.
you can log into that local network, and run the code below

2.
For more flexibility, the flatcat can also log into a different WiFi
(so you can keep internet connections etc etc).
From the flatcat app page
https://flatcat22.local
one can set which local WiFi to log into;
the flatcat will keep its own access point open
so the app page always is accessible,
and ssh into the flatcat raspberry pi.

// debugging
OSCdef.trace;
OSCdef.trace(false);

// turn flatcat-NTMI connection off and on:
OSCdef(\flatcat).disable;
OSCdef(\flatcat).enable;

*/

// the OSC port number flatcat sends on
thisProcess.openUDPPort(8999);

// keep memory of data ranges for dynamically scaling data
~minmax = 15.collect { [nil,nil] };

/**** The incoming data from the flatcat consist of:
Ubat - battery/charger voltage
Ubus - bus voltage measured by energymodule
Umot - motors' supply voltages
and 3x4 values for the three joint motors:
temperature
position // angle
velocity
current

// TODO:
- replace measured data ranges with known good ones.
- simple recent data display, last 5 seconds,
- ringbuf or so.

***/


OSCdef(\flatcat, { |msg|
	var nums = msg.drop(1);
	var bipolars;
	// measure flatcat sending frame rate
	~now = Main.elapsedTime;
	~dt = ~now - (~then ? ~now);
	~then = ~now;

	// forget supply voltages for now
	nums = nums.drop(3);

	// update data ranges
	nums.do { |val, i|
		var minmax = ~minmax[i];
		minmax[0] = min(minmax[0] ? val, val);
		minmax[1] = max(minmax[1] ? val, val)
	};

	// scale to bipolar range for influx inputs
	~bipolars = nums.collect { |num, i|
		var range = ~minmax[i];
		num.linlin(range[0], range[1], -1, 1);
	};
	// remove supply voltage status values?
	~bipolars = ~bipolars.drop(3);

	// crude, but works:
	// set 12 (or 15) first influx inputs from flatcat
	NTMI.inphlux.set(*~bipolars.collect { |num, i|
		[ NTMI.inphlux.inNames[i], num ]
	}.flat);

	////// debug
	// msg.round(0.001).postln;
	// "~dt: %\n".postf(~dt.round(0.001));
}, '/flatcat').enable;

