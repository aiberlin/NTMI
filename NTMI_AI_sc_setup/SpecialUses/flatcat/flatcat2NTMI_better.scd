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

///// GUI stuff:
/* // put at the end of your startup:
NTMI.addInterfaceFile(\flatcat, "SpecialUses/flatcat2NTMI_better.scd");
NTMI.addInterfaceFile(\flatcatViz, "SpecialUses/flatcat_viz.scd");
*/

// add number readouts to gui:
WinBounds.addMake(\flatcat, {
	var mg = MKtl(\flatcat).gui.showLabels;
	var win = mg.parent;
	var uv = UserView(win, win.view.bounds.top_(200).height_(30))
	.background_(Color.grey);
	win.bounds = win.bounds.height_(win.bounds.height + 30);
	uv.drawFunc = { |uv|
		var string = MKtl(\flatcat).elAt.deviceValue.collect { |val|
			(val.round(0.001).asString ++ " ").clipExtend(5)
		};
		Pen.stringCenteredIn(string.join(" "),
			uv.bounds.extent.asRect,
			Font(Font.defaultMonoFace, 16.5),
			Color.green);
	};
	uv.frameRate_(10).animate_(true);
	win;
});
WinBounds.showOrMake(\flatcat);
);

/***
// to send a test message without flatcat,
// you need to adjust the source Address in the MKtl OSC device:
MKtl(\flatcat).device.updateSrcAddr("127.0.0.1", NetAddr.langPort);
OSCFunc.trace(true, true);
// then this line should change the flatcat values:
~sendFlatcatRand.value;

// to switch back to real flatcat address, do:
MKtl(\flatcat).device.updateSrcAddr("192.168.4.1", 46757);



***/
~sendFlatcatRand = {
	NetAddr("127.0.0.1", 8999).sendMsg("/flatcat",
		// voltages:
		4.1, 5.8, 5.9,
		// temp, angle, velo, current
		rrand(25.0, 40), 0.5.rand2, 0.2.rand2, 0.2.rand2,
		rrand(25.0, 40), 0.5.rand2, 0.2.rand2, 0.2.rand2,
		rrand(25.0, 40), 0.5.rand2, 0.2.rand2, 0.2.rand2,
	);
};
/*
~sendFlatcatRand.value;
*/




// MFdef(\flatcat): the actions to do when data come in
(
MKtl(\flatcat).collAt(\alldata).action = MFdef(\flatcat);

// simplest: post normalized data
MFdef(\flatcat).add(\post, { |el|
	"*** flatcat alldata: ".postln;
	el.value.round(0.001).postln;
});
/*
MFdef(\flatcat).disable(\post);
MFdef(\flatcat).enable(\post);
*/
MFdef(\flatcat).disable(\post);

OSCdef(\flatcat2mktl, { |msg, time, senderAddr, recvPort|
	"*** flatcat - updating source to: %\n".postf(senderAddr);
	MKtl(\flatcat).device.updateSrcAddr(senderAddr.addr.asIPString, senderAddr.port);
	OSCdef(\flatcat2mktl).disable;
	"*** updated to:".post;
	MKtl(\flatcat).device.source.postln;
}, \flatcat).enable;

// set absolute:
MFdef(\flatcat).add(\setAbs, {
	// var debug = "MFdef('flatcat') - setAbs".postln;
	var values = MKtl(\flatcat).elAt.value;
	var bipolars = values.drop(3).unibi;

	NTMI.inphlux.set(
		*[ NTMI.inphlux.inNames.keep(values.size),
			bipolars].flop.flat;
	);
});
/*
MFdef(\flatcat).disable(\setAbs);
MFdef(\flatcat).enable(\\setAbs);
*/
);

/* play an NTMI sound slot
NTMI.slots.playAt(0);
*/

MKtl(\flatcat).elAt.action = { |el|
	// var debug = "flatcat global".postln;
	// value change should set all other indiv. elements,
	// so prevValues are correctly 0:
	MKtl(\flatcat).elAt.do { |el2|
		if (el2 != el) { el2.value = el2.value };
	};
	// then trigger global set had come in:
	MKtl(\flatcat).collAt(\alldata).doAction;
};
/*
~sendFlatcatRand.value;
*/

// SET-RELATIVE => Polyphonic INFLUENCE MODE !
MFdef(\flatcat).disable(\setAbs);

// use NTMI.zooms.flatcat to tune its degree of influence
NTMI.zooms = NTMI.zooms ? ();
NTMI.zooms.flatcat = 1;


MFdef(\flatcat).add(\setRel, {
	// var debug = "MFdef('flatcat') - setRel".postln;
	var values = MKtl(\flatcat).elAt.value;
	var diffs = values - MKtl(\flatcat).elAt.prevValue;
	diffs = diffs.drop(3);

	// influence the playing slots
	MFdef(\setRelInf).(
		(0..diffs.size-1),
		diffs,
		NTMI.inphlux.inScaler
		* NTMI.zooms.flatcat
	);
});
MFdef(\flatcat).enable(\setRel);

MKtl(\flatcat);