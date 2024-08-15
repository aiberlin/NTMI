/*
This file shows how to receive flatcat data,
how to do some statistics to understand them,
how to map them to an control Ndef,
and how to connect them to the NTMI setup by setting the influx inputs.

The flatcat is a robot pet made by jetpack cognition lab:
"https://flatcat.berlin".openOS;

It has three joints which sense the forces affecting them,
and decides on movements based on this connection to its environment.
In an experimental version of its code, it sends out an OSC message
with sensor data, planned motor control currents, and motor temperatures.
https://gitlab.com/jetpack-cognition-lab/flatcat_ux0/
https://gitlab.com/jetpack-cognition-lab/flatcat_ux0/-/tree/osc?ref_type=heads


There are two ways to connect to the flatcat:
1. The flatcat has its own WiFi access point called flatcat00,
where 00 is replaced by the flatcat serial number, 22 in my case.
You can log into that local network, and run the code below

2. For more flexibility, the flatcat can also log into a different local WiFi,
so you can keep internet connections etc.

From the flatcat app page:
"https://flatcat22.local".openOS;
one can set which local WiFi to log into;
the flatcat will keep its own access point open
so the app page always is accessible,
and one can ssh into the flatcat raspberry pi.


******* Steps to run flatcat and NTMI: ****
# turn on flatcat

# on laptop, choose Wifi flatcat00 / pw: fl4tc4t*

# In Terminal, log into the flatcat raspi with:
ssh pi@flatcat22.local
# pw: fl4tc4t*

# In Terminal, stop the default robot program:
killall ux0_serial

# and start the osc-modified one:
cd jetpack/flatcat_ux0/
./ux0_serial_osc -l -d


/**** debugging: ****/
// open the OSC port number flatcat sends on
thisProcess.openUDPPort(8999);
// trace that we get messages from flatcat
OSCdef.trace(true, true);
OSCdef.trace(false);

// later, use this to turn flatcat-NTMI connection off and on:
OSCdef(\flatcat).disable;
OSCdef(\flatcat).enable;

*/

/**** The incoming data from the flatcat consist of:
Ubat - battery/charger voltage
Ubus - bus voltage measured by energymodule
Umot - motors' supply voltages
and 3x4 values for the three joint motors:
temperature
position // angle
velocity
current

***/

(
// the OSC port number flatcat sends on
thisProcess.openUDPPort(8999);

// keep memory of data ranges for dynamically scaling data
~minmax = 15.collect { [nil,nil] };
~flatcatkeys = [ 'ubat', 'ubus', 'umot',
	'temper0', 'angle0', 'velo0', 'curr0',
	'temper1', 'angle1', 'velo1', 'curr1',
	'temper2', 'angle2', 'velo2', 'curr2' ];


/// measuring the data from flatcat :

OSCdef(\flatStat, { |msg|
	var nums = msg.drop(1);
	var bipolars;
	// measure flatcat sending frame rate
	~now = Main.elapsedTime;
	~dt = ~now - (~then ? ~now);
	~then = ~now;
	~avgdt = blend(~avgdt ? ~dt, ~dt, 0.9);

	// capture data ranges
	nums.do { |val, i|
		var minmax = ~minmax[i];
		minmax[0] = min(minmax[0] ? val, val);
		minmax[1] = max(minmax[1] ? val, val)
	};

}, '/flatcat').enable;
);

~postStatistics = {
	("*** framerate:" + (1/~avgdt.round(0.001))).postln;
	("*** measured ranges:").postln;
	[ ~flatcatkeys, ~minmax.round(0.001)].flop.printAll; "";
};
/*
~postStatistics.value;
*/


(
// make an Ndef to show current raw values
// the specs are measured reasonable ranges
[ 'ubat', 'ubus', 'umot'].do { |u| Spec.add(u, [2.5, 6.5]) };
[ 'temper0', 'temper1', 'temper2' ].do { |t| Spec.add(t, [10, 60]) };
[ 'angle0', 'angle1', 'angle2' ].do { |u| Spec.add(u, [-0.5, 0.5]) };
[ 'velo0', 'velo1', 'velo2' ].do { |u| Spec.add(u, \bipolar) };
[ 'curr0', 'curr1', 'curr2' ].do { |u| Spec.add(u, [-0.5, 0.5]) };

Ndef(\flatcatKr, { |ubat=4, ubus = 6, umot = 5.8,
	temper0 = 25, angle0 = 0, velo0 = 0, current0 = 0,
	temper1 = 25, angle1 = 0, velo1 = 0, current1 = 0,
	temper2 = 25, angle2 = 0, velo2 = 0, current2 = 0|

	[ ubat, ubus, umot,
	temper0, angle0, velo0, current0,
	temper1, angle1, velo1, current1,
	temper2, angle2, velo2, current2
	].lag(0.1);
});
Ndef(\flatcatKr).gui;
);

// modify OSCdef so it sets the Ndef for simple display,
// and so it hard-sets the NTMI.inphlux inputs.
// this works well, but in the long run, relative setting
// (just influencing) the influx is more flexible.
(
~flatcatNtmiKeys = ~flatcatkeys.drop(3);
~flatcatSpecs = ~flatcatkeys.collect { |param| Ndef(\flatcatKr).getSpec(param) };

OSCdef(\flatcat, { |msg|
	var nums = msg.drop(1);
	var bipolars;

	Ndef(\flatcatKr).set(*[~flatcatkeys, nums].flop.flat);

	// scale to bipolar range for influx inputs
	~bipolars = nums.collect { |num, i|
		~flatcatSpecs[i].unmap(num) * 2 - 1;
	};
	// remove supply voltage status values?
	~bipolars = ~bipolars.drop(3).reverse;

	// crude, but works as first pass:
	// absolute-set 12 (or 15) first influx inputs from flatcat
	NTMI.inphlux.set(*~bipolars.collect { |num, i|
		[ NTMI.inphlux.inNames[i], num ]
	}.flat);

}, '/flatcat');
OSCdef(\flatcat).enable;
);

NTMI.slots.playAt(0);
/*
NTMI.slots.toggleAt(0);
NTMI.slots.toggleAt(1);
NTMI.slots.toggleAt(2);
NTMI.slots.toggleAt(3);
*/