/*
This file shows how to receive flatcat data,
how to make a modal control object, an MKtl for the flatcat,
and how to use that MKtl to influence the NTMI setup
by relative-setting its influx inputs.

The flatcat is a robot pet made by jetpack cognition lab:
"https://flatcat.berlin".openOS;

It has three joints which sense the forces affecting them,
and decides on movements based on this connection to its environment.
In an experimental version of its code, it sends out an OSC message
with sensor data, planned motor control currents, and motor temperatures.
https://gitlab.com/jetpack-cognition-lab/flatcat_ux0/
https://gitlab.com/jetpack-cognition-lab/flatcat_ux0/-/tree/osc?ref_type=heads


******* Steps to run flatcat and NTMI: ****
# turn on flatcat

# on laptop, choose Wifi flatcat00 / pw: fl4tc4t*
* 00 is replaced with the flatcat serial number

# In Terminal, log into the flatcat raspi with e.g.
ssh pi@flatcat22.local
# pw: fl4tc4t*

# if the flatcat does not start with OSC by default:
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

// turn posting for debugging on/off:
NTMI.flatcat.debugOn = true;
NTMI.flatcat.debugOn = false;


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

NTMI.flatcat = NTMI.flatcat ? ();

MKtl.all[\flatcat].free;
MKtl(\flatcat, "flatcat.desc.scd".loadRelative.unbubble);

MKtl(\flatcat).elAt.deviceValue = [
	4.1, 5.8, 5.9,
	// temp, angle, velo, current
	rrand(25.0, 40), rrand(25.0, 40), rrand(25.0, 40),
	0.5.rand2, 0.5.rand2, 0.5.rand2,
	0.2.rand2, 0.2.rand2, 0.2.rand2,
	0.2.rand2, 0.2.rand2, 0.2.rand2,
];

/***
// to send a test message without a flatcat,
// you need to adjust the source Address in the MKtl OSC device.
MKtl(\flatcat).device.updateSrcAddr("127.0.0.1", NetAddr.langPort);
OSCFunc.trace(true, true);
// then this line should change the flatcat values:
~sendFlatcatRand.value;

// to switch back to real flatcat address, do:
MKtl(\flatcat).device.updateSrcAddr("192.168.4.1", 46757);
***/

NTMI.flatcat.sendRand = {
	NetAddr("127.0.0.1", 8999).sendMsg("/flatcat",
		// voltages:
		rrand(4.0, 4.5), rrand(5.5, 6.0), rrand(5.5, 6.0),
		// temp, angle, velo, current
		rrand(25.0, 40), 0.5.rand2, 0.2.rand2, 0.2.rand2,
		rrand(25.0, 40), 0.5.rand2, 0.2.rand2, 0.2.rand2,
		rrand(25.0, 40), 0.5.rand2, 0.2.rand2, 0.2.rand2,
	);
};

// change current values by a little drift
NTMI.flatcat.sendDrift = { |fc, drift = 0.05|
	var vals = MKtl(\flatcat).elAt.collect { |el|
		el.deviceSpec.map((el.value + drift.bilinrand))
	};
	// reorder
	vals = vals.keep(3) ++ vals.drop(3).clump(3).flop.flat;
	NetAddr("127.0.0.1", 8999).sendMsg("/flatcat", *vals);
};
/*
NTMI.flatcat.sendRand.value;
NTMI.flatcat.sendDrift.value;
*/

// simulate slowly drifting flatcat moves
Tdef(\flatcatSim).addSpec(\drift, [0, 0.1]);
Tdef(\flatcatSim).set(\drift, 0.03);

Tdef(\flatcatSim, { |env|
	loop {
		0.05.wait;
		NTMI.flatcat.sendDrift(env.drift);
	}
});
/*
Tdef(\flatcatSim).play;
Tdef(\flatcatSim).stop;
*/


// NTMI.flatcat.onData: the actions to do when data come in
NTMI.flatcat.onData = MFunc();

/*
// onData eventually has these functions:
NTMI.flatcat.onData.disable(\post);
NTMI.flatcat.onData.disable(\meta);
NTMI.flatcat.onData.disable(\vizdata);
NTMI.flatcat.onData.disable(\setRel);
NTMI.flatcat.onData.disable(\setAbs);
*/

// switching setAbs/Rel as in other interfaces
NTMI.flatcat.setAbs = {
	NTMI.flatcat.onData.enable(\setAbs);
	NTMI.flatcat.onData.disable(\setRel);
	NTMI.flatcat.influxMode = \setAbs;
	"NTMI.flatcat.influxMode is %\n".postf(NTMI.flatcat.influxMode);
};

NTMI.flatcat.setRel = {
	NTMI.flatcat.onData.enable(\setRel);
	NTMI.flatcat.onData.disable(\setAbs);
	NTMI.flatcat.influxMode = \setRel;
	"NTMI.flatcat.influxMode is %\n".postf(NTMI.flatcat.influxMode);
};

(
MKtl(\flatcat).collAt(\alldata).action = NTMI.flatcat.onData;

// simplest: post normalized data
NTMI.flatcat.onData.add(\post, { |el|
	"*** flatcat alldata: ".postln;
	el.value.round(0.001).postln;
});
NTMI.flatcat.onData.disable(\post);
/*
NTMI.flatcat.onData.disable(\post);
NTMI.flatcat.onData.enable(\post);
*/

OSCdef(\flatcat2mktl, { |msg, time, senderAddr, recvPort|
	"*** flatcat - updating source to: %\n".postf(senderAddr);
	MKtl(\flatcat).device.updateSrcAddr(senderAddr.addr.asIPString, senderAddr.port);
	OSCdef(\flatcat2mktl).disable;
	"*** updated to:".post;
	MKtl(\flatcat).device.source.postln;
}, \flatcat).enable;

// set absolute:
NTMI.flatcat.onData.add(\setAbs, {
	// var debug = "MFdef('flatcat') - setAbs".postln;
	var values = MKtl(\flatcat).elAt.value;
	var bipolars = values.drop(3).unibi * NTMI.flatcat.zoom;

	NTMI.inphlux.set(
		*[ NTMI.inphlux.inNames.keep(values.size),
			bipolars].flop.flat;
	);
	\setAbs
});
);

MKtl(\flatcat).elAt.action = nil;

// this is needed to make the gui behave well:
// when an element sets gets used, set all values again,
// so that group.prevValue gets the correct differences.
MKtl(\flatcat).elAt.action = { |el|
	MKtl(\flatcat).elAt.value = MKtl(\flatcat).elAt.value;
//	MKtl(\flatcat).collAt(\alldata).doAction;
};

NTMI.flatcat.zoom = 1;

// SET-RELATIVE => Polyphonic INFLUENCE MODE !
NTMI.flatcat.onData.add(\setRel, {
	// var debug = "MFdef('flatcat') - setRel".postln;
	var values = MKtl(\flatcat).elAt.value;
	var diffs = values - MKtl(\flatcat).elAt.prevValue;
	diffs = diffs.drop(3);

	// influence the playing slots
	MFdef(\setRelInf).(
		(0..diffs.size-1),
		diffs,
		NTMI.inphlux.inScaler
		* NTMI.flatcat.zoom
	);
	\setRel
});


NTMI.flatcat.influxMode = NTMI.flatcat.influxMode ? \setRel;
NTMI.flatcat.perform(NTMI.flatcat.influxMode);

MKtl(\flatcat);
)
