/*
This file connects the Kraken built by Kuntay Seferoglu
to NTMI as a multi-person interface.

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

******** ******** ******** ********

SerialPort.devices;
SerialPort.closeAll;

q.octo.rout.stop;
q.octo.serial.close;

// do sth in func:
MFdef(\kr_pots).add(\post, {|v| v.postln; });
MFdef(\kr_buts).add(\post, {|v| v.postln; });
MFdef(\kr_ribs).add(\post, {|v| v.postln; });

MFdef(\kr_buts).disable(\post);
MFdef(\kr_ribs).disable(\post);
MFdef(\kr_pots).disable(\post);

*/

(

q.octo = q.octo ? ();

// open Serial port:
(

q.octo.serial = SerialPort(
	"/dev/tty.usbmodem*".pathMatch.first,    //edit to match your port. SerialPort.listDevices
	baudrate: 115200,    //check that baudrate is the same as in arduino sketch
	crtscts: true);
);

// read serial data sent from Arduino's Serial.println> we get 3 strings:
// b[0,0,1...] for 10 buttons,
// p[123,1023,...] for 10 pots, 10bit, i.e. 0-1023, and
// r[0,500,1023,0] for 4 ribbons, also 10bit.

(
try{q.octo.rout.stop};
q.octo.rout = Routine({
	var byte, str, res;
	var t0 = Main.elapsedTime;
	var t = t0;
	inf.do { |i|
		if(q.octo.serial.read==10, {
			var key, array;
			str = "";
			while({byte = q.octo.serial.read; byte !=13 }, {
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

//// Make an MKtl for the Kraken
(
~krakDesc = (
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
				key: 'bt',
				shared: ( elementType: 'button', ioType: \collectiveIn, \spec: \but ),
				elements: 8.collect { () }
			),
			(
				key: 'kn',
				shared: ( elementType: 'knob', ioType: \collectiveIn, \spec: [0, 1023] ),
				elements: 8.collect { () }
			),
			// ribbons are on 2, 4, 7, 9
			(
				key: 'ribbon',
				shared: ( elementType: 'slider', ioType: \collectiveIn, \spec: [0, 1023] ),
				elements: 3.collect { |i| (
					style: (column: [1, 3, 6, 8][i])
				) }
			),

		]
	)
);
);

MKtl(\kraken).free;
m = MKtl( \kraken, ~krakDesc );
m.trace.gui;

// do valueActions in MKtl only when changed:
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

//////////////////// Now attach to NTMI - quick and dirty

// raw influx - ugly but would work
// influx first:
MFdef(\kr_pots).add(\influx, { |rawvals|
	var values = rawvals.linlin(0, 1023, -1, 1);
	var inNames = q.inphlux.inNames.keep(values.size);
	q.inphlux.set(*[inNames, values].flop.flat);
});

MFdef(\kr_ribs).add(\influx, { |rawvals|
	var values = rawvals.linlin(0, 1023, 0, 1) * [-1, 1];
	var inNames = q.inphlux.inNames.drop(10).keep(values.size);
	q.inphlux.set(*[inNames, values].flop.flat);
});
MFdef(\kr_ribs).disable(\influx);
MFdef(\kr_pots).disable(\influx);


/*****

simple Logic 1 :
all knobs and ribbons go to influx directly
first four buttons activate sound in slots 1-4;
second four buttons switch preset or sound process in slots 1-4;
******/

MKtl( \kraken).elAt(\kn).action = { |el|
	var inName = q.inphlux.inNames[8 + el.indexInGroup];
	q.inphlux.set(inName, el.value * 2 - 1);
};

MKtl( \kraken).elAt(\ribbon).action = { |el|
	var inName = q.inphlux.inNames[5 + el.indexInGroup];
	q.inphlux.set(inName, el.value * 2 - 1);
};

MKtl( \kraken).elAt(\bt, (0..3)).do(_.action = { |el|
	var slotNum = el.indexInGroup.postln;
	if (el.isOn) {
		q.slots.playAt(slotNum)
	} {
		q.slots.stopAt(slotNum)
	};
});

MFdef.all.keys(SortedList);

q.slots.addActive(i, Ndef(pop.item));

MKtl(\kraken).elAt(\bt, (4..7)).do(_.action = { |el|
	var slotNum = (el.indexInGroup - 4).postln;
	var nextSnd, nextPre;
	if (el.isOn) {
		if (0.1.coin) {
			q.slots.addActive(slotNum, Ndef(q.slots.choices[slotNum].choose));
			q.slots.playAt(slotNum);
		} {
			MFdef(\stepSlotPres).(slotNum)
		}
	};
});



/*****
deeper Logic 2 :
all knobs and ribbons go to influx, but relative;

all eight buttons do the same:
when pressed, they grab a slot and and own it:
play my own sound on it
hold to keep playing that sound,
press 2 times quickly -> new rand preset
press 3 times quickly -> new rand sound

*****/



q.octo.prevButs = 0!10;
q.octo.prevButs = 0!10;

q.octo.slotButs = [0, 1, 2, 3];

MFdef.all.keys(Array).sort;

MFdef(\inphModeSetIndex).value(1);

q.slots.keys(Array);

q.slots.actives.collect(_.isPlaying).selectIndices (_ == true);

MFdef(\randBut).add(\rand, {
	\randBut.postln;
	[
		// switch an active sound
		{
			var nowPlayingIndices = q.slots.actives.collect(_.isPlaying)
			.selectIndices (_ == true);
			var indexToChange = nowPlayingIndices.choose;
			if (indexToChange.notNil) {
				q.slots.chooseNext(indexToChange);
				q.slots.playAt(indexToChange)
			};
		},
		// switch an active preset
		// {
		// 	var nowPlayingIndices = q.slots.actives.collect(_.isPlaying)
		// 	.selectIndices (_ == true);
		// 	var indexToChange = nowPlayingIndices.choose;
		// 	if (indexToChange.notNil) {
		// 		q.slots.keys
		// 		(indexToChange);
		// 		q.slots.playAt(indexToChange)
		//
		// 	},
		// switch influx preset
		{ MFdef(\inphModeStep).value },
		// switch rand mainFX preset
		{ MFdef(\mainPreStep).value },
	].choose.value;
});

// 2, 4, 7, 9 have ribbons

MFdef(\kr_buts).add(\trig, { |vals|
	vals = vals.keep(8);
	vals.do { |val, i|
		if (val != q.octo.prevButs[i]) {
			"but % is now %\n".postf(i, val);
			// first four buttons toggle sounds on /off
			if (i < 4) {
				if (val == 0) {
					q.slots.stopAt(i)
				} {
					q.slots.playAt(i)
				};
			} {
				// all other buttons change something randomly
				if (val > 0) { MFdef(\randBut).value }
			};
		};
	};
	q.octo.prevButs = vals;
});