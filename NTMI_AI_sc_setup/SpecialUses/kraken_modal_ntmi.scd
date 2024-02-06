/*
This file connects the Kraken built by Kuntay Seferoglu
to NTMI as a multi-person interface.

// to add the kraken file/gui file to Butz->interfaces:
NTMI.addInterfaceFile(\kraken, NTMI.dir.setup +/+ "SpecialUses/kraken_modal_ntmi.scd");


******** Status April 5 2023 ********
buttons> 1-8 are OK,
9 is dead, 10 is touch/sensitive, but crackles on&off

pots> 1-5, 7 OK,
6 works, but also controls ribbon 3 (at pos 7)
8 works, but also reverse-controls pot 9 (0-> 1023, 1023-> 0)
pot 9 is disconnected
pot 10 works

ribbon 1 (on 2) works
ribbon 2 (on 4) works
ribbon 3 (on 7) rib does nothing, gets value from pot
ribbon 4 (on 9) does nothing at all

->>>>> !!!! only use 8 krakens for NOW (Oktopus)!!!!!!

******** Debug ******** ********

SerialPort.devices;
SerialPort.closeAll;

NTMI.kraken.rout.stop;
NTMI.kraken.serial.close;

// do sth in func:
MFdef(\kr_pots).add(\post, {|v| v.postln; });
MFdef(\kr_buts).add(\post, {|v| v.postln; });
MFdef(\kr_ribs).add(\post, {|v| v.postln; });

MFdef(\kr_buts).disable(\post);
MFdef(\kr_ribs).disable(\post);
MFdef(\kr_pots).disable(\post);

*/

(
NTMI.kraken = NTMI.kraken ? ();

// open Serial port:
(
SerialPort.closeAll;

//edit to match your port. see SerialPort.listDevices
NTMI.kraken.devname = "/dev/tty.usbmodem*".pathMatch.first;

if (NTMI.kraken.devname.isNil) {
	"NTMI.kraken: could not find device matching \"/dev/tty.usbmodem*\"".warn;
	"continuing with virtual device.".postln
} {

	NTMI.kraken.serial = SerialPort(
		NTMI.kraken.devname,
		baudrate: 115200,    //check that baudrate matches w arduino sketch
		crtscts: true
	).postln;


	// read serial data sent from Arduino's Serial.println> we get 3 strings:
	// b[0,0,1...] for 10 buttons,
	// p[123,1023,...] for 10 pots, 10bit, i.e. 0-1023, and
	// r[0,500,1023,0] for 4 ribbons, also 10bit.

	(
		try{NTMI.kraken.rout.stop};
		NTMI.kraken.rout = Routine({
			var byte, str, res;
			var t0 = Main.elapsedTime;
			var t = t0;
			inf.do { |i|
				if(NTMI.kraken.serial.read==10, {
					var key, array;
					str = "";
					while({byte = NTMI.kraken.serial.read; byte !=13 }, {
						str = str++byte.asAscii;
					});
					try {
						// str.postln;
						key = str.first;
						// turn code string into number array
						array = str.drop(1).interpret;
						case(
							{key == $p}, { MFdef(\kr_pots).value(array) },
							{key == $b}, { MFdef(\kr_buts).value(array) },
							{key == $r}, { MFdef(\kr_ribs).value(array) },
						);
					};
					// key.cs.post;
				});
				t = Main.elapsedTime;
				// "%, ".postf((t - t0).round(0.0001));
				t0 = t;
			};
		}).play;
	);
};
);

//// Make an MKtl description for the Kraken
(

NTMI.kraken.desc = (
	idInfo: ( ipAddress: "127.0.0.1" ),
	protocol: \osc,
	collectives: (
		bt: (
			oscPath: 'bt',
			// the order in this array determines the order how the message is parsed
			elements: [ [\bt,0], [\bt,1], [\bt,2], [\bt,3],
				[\bt,4], [\bt,5], [\bt,6], [\bt,7] ],
			ioType: \in
		),
		kn: (
			oscPath: 'kn',
			// the order in this array determines the order how the message is parsed
			elements: [ [\kn,0], [\kn,1], [\kn,2], [\kn,3],
				[\kn,4], [\kn,5], [\kn,6], [\kn,7] ],
			ioType: \in
		),


	),

	elementsDesc: (
		elements: [
			(
				key: 'kn',
				shared: ( elementType: 'knob', ioType: \collectiveIn, \spec: [0, 1023] ),
				elements: 8.collect { () }
			),
			(
				key: 'bt',
				shared: ( elementType: 'button', ioType: \collectiveIn, \spec: \but ),
				elements: 8.collect { |i| (style: (height: 0.5, column: i)) }
			),
			// ribbons are on 2, 4, 7, 9
			(
				key: 'ribbon',
				shared: ( elementType: 'slider', ioType: \collectiveIn, \spec: [0, 1023] ),
				elements: 3.collect { |i| (
					style: (column: [1, 3, 6, 8][i], height: 0.5, width: 2))
				}
			),

		]
	)
);
);

// Make an MKtl for the kraken
(
MKtl.all.kraken.free;
MKtl( \kraken, NTMI.kraken.desc );

// pipe serial input data into the kraken MKtl
// do valueActions in MKtl only when values changed:
MFdef(\kr_buts).add(\store, { |rawvals|
	var krakButs = MKtl(\kraken).elAt(\bt);
	rawvals.do { |val, i|
		var bt = krakButs[i];
		if (bt.deviceValue != val) {
			bt.deviceValueAction_(val);
		}
	}
});

MFdef(\kr_pots).add(\store, { |rawvals|
	var krakEls = MKtl(\kraken).elAt(\kn);
	rawvals.do { |val, i|
		var el = krakEls[i];
		// ignore light pot jitter, observed 1-2 steps,
		if (el.deviceValue.absdif(val) > 2) {
			el.deviceValueAction_(val);
		}
	}
});

MFdef(\kr_ribs).add(\store, { |rawvals|
	var krakEls = MKtl(\kraken).elAt(\ribbon);
	rawvals.do { |val, i|
		var el = krakEls[i];
		// ignore light ribbon jitter, observed 1-2 steps,
		if (el.deviceValue.absdif(val) > 2) {
			el.deviceValueAction_(val);
		}
	}
});
);


// add 3 test actions:
MKtl( \kraken).elAt(\bt).action = { |el| [el.name, el.value].postln };
MKtl( \kraken).elAt(\kn).action = { |el| [el.name, el.deviceValue].postln };
MKtl( \kraken).elAt(\ribbon).action = { |el| [el.name, el.deviceValue].postln };


/*****
1 simple Logic :
all knobs and ribbons go to influx directly
first four buttons activate sound in slots 1-4;
second four buttons switch preset or sound process in slots 1-4;
******/
// first pass at buttons:
// buttons 0-3 turn sound on and off
MKtl( \kraken).elAt(\bt, (0..3)).do(_.action = { |el|
	var slotNum = el.indexInGroup.postln;
	if (el.isOn) { NTMI.slots.toggleAt(slotNum) };
});

// buttons 4-7 randomly choose new sounds or presets
MKtl(\kraken).elAt(\bt, (4..7)).do(_.action = { |el|
	var slotNum = (el.indexInGroup - 4).postln;
	var nextSnd, nextPre;
	if (el.isOn) {
		if (0.1.coin) {
			// 10% of the times, start a new sound
			"kraken: new sound at %\n".postf(slotNum);
			NTMI.slots.stepNext(slotNum);
			NTMI.slots.playAt(slotNum);
		} {
			// 90%, switch to a random preset
			"kraken: new preset at %\n".postf(slotNum);
			NTMI.pre.stepNdefInf(NTMI.ndefs[slotNum]);
		}
	};
});
);


///////////// INflux: ////////////

NTMI.kraken.zoom = NTMI.kraken.zoom ? 1;

NTMI.kraken.inflAction = MFunc();
MKtl( \kraken).elAt(\kn).action = NTMI.kraken.inflAction;
MKtl( \kraken).elAt(\ribbon).action = NTMI.kraken.inflAction;

NTMI.kraken.influxMode = \setRel;
NTMI.kraken.setRel = {
	"NTMI.kraken.influxMode = \\setRel;".postln;
	NTMI.kraken.influxMode = \setRel;
};
NTMI.kraken.setAbs = {
	"NTMI.kraken.influxMode = \\setAbs;".postln;
	NTMI.kraken.influxMode = \setAbs;
};

NTMI.kraken.influxNames = (
	kn: (8..15),
	ribbon: (5..7)
);

NTMI.kraken.inflAction.add(\which, { |el|
	if (NTMI.kraken.influxMode == \setAbs) {
		NTMI.kraken.inflAction[\setAbs].(el);
	} {
		NTMI.kraken.inflAction[\setRel].(el);
	};
});

NTMI.kraken.inflAction.add(\setAbs, { |el|
	var groupname = el.parent.name;
	var inNames = NTMI.kraken.influxNames[groupname];
	var inName = inNames[el.indexInGroup];
	\setAbs.postln;
	NTMI.inphlux.set(inName,
		el.value * 2 - 1
		* NTMI.zoom * NTMI.kraken.zoom
	);
}, false);


NTMI.kraken.inflAction.add(\setRel, { |el|
	var groupname = el.parent.name;
	var inNames = NTMI.kraken.influxNames[groupname];
	var inName = inNames[el.indexInGroup];

	MFdef(\setRelInf).(
		el.indexInGroup + 8,
		(el.value - el.prevValue),
		NTMI.zoom * NTMI.kraken.zoom
	);
}, false);

