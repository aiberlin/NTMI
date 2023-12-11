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

// make an MKtl description dict for the flatcat:
~flatcatdesc = (
	descName: "flatcat",
	deviceName: "flatcat",
	protocol: \osc,
	deviceType: \robotPet,
	elementTypes: [\sensor],
	status: (
		linux: "unknown",
		osx: "unknown",
		win: "unknown"
	),

	idInfo: "flatcat",
	// info for flatcat in accesspoint mode
	netAddrInfo: (ipAddress: "192.168.4.1", srcPort: 46757, recvPort: 8999 ),

	deviceInfo: (
		vendorURI: "https://flatcat.berlin",
		description: "robot pet",
		features: [
		],
		longName: "jetpack lab flatcat",
		notes: "",
	),

	specs: (

		'voltage': [2.5, 6.5],

		'temper': [10, 60],
		'angle': [-0.5, 0.5],
		'velo': \bipolar,
		'curr': [-0.5, 0.5]
	),

	collectives: (
		alldata: (
			oscPath: '/flatcat',
			elements: [
				[\ubat], [\ubus], [\umot],

				[\temper0], [\angle0], [\velo0],[\curr0],
				[\temper1], [\angle1], [\velo1], [\curr1],
				[\temper2],[\angle2], [\velo2], [\curr2],
			],
			ioType: \in
		),
	),

	elementsDesc: (
		// input elements:
		shared: (elementType: 'slider', ioType: \collectiveIn),

		elements: [

			( key: \ubat, \spec: 'voltage' ),
			( key: \ubus, \spec: 'voltage' ),
			( key: \umot, \spec: 'voltage' ),

			( key: \temper0, \spec: 'temper' ),
			( key: \temper1, \spec: 'temper' ),
			( key: \temper2, \spec: 'temper' ),

			( key: \angle0, \spec: 'angle' ),
			( key: \angle1, \spec: 'angle' ),
			( key: \angle2, \spec: 'angle' ),

			( key: \velo0, \spec: 'velo' ),
			( key: \velo1, \spec: 'velo' ),
			( key: \velo2, \spec: 'velo' ),

			( key: \curr0, \spec: 'curr' ),
			( key: \curr1, \spec: 'curr' ),
			( key: \curr2, \spec: 'curr' )
		]
	)
);
MKtl.all[\flatcat].free;
MKtl(\flatcat, ~flatcatdesc);


///// GUI stuff:
NTMI.addInterfaceFile(\flatcat, "SpecialUses/flatcat2NTMI_better.scd");

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


// set absolute: post normalized data
MFdef(\flatcat).add(\setAbs, {
	var debug = "MFdef('flatcat') - setAbs".postln;
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
	var debug = "flatcat global".postln;
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
	///////// maybe make changevectors by hand later:
	// var changeVector = NTMI.inphlux.changeVector(
	// 	(0..diffs.size - 1),
	// 	diffs,
	// 	0.3
	// );
	// diffs.postln;
	// changeVector.postln;

	// for now, influence the playing slots
	NTMI.slots.nowPlaying.do { |ndef|
		// unless they are decoupled ?
		if (NTMI.inph.decoupled.includes(ndef.key).not) {
			var numParams = ndef.controlKeys.size;
			NTMI.inphlux.setRel(ndef,
				(0..numParams-1),
				diffs,
				NTMI.inphlux.inScaler
				* NTMI.zooms.flatcat
			);
		};
	};
});
MFdef(\flatcat).enable(\setRel);

MKtl(\flatcat);