/*****
2 more complex Logic idea:
all knobs and ribbons go to influx, but relative;

all eight buttons do the same:
when pressed, they grab a slot and and own it:
play my own sound on it
hold to keep playing that sound,
press 2 times quickly -> new rand preset
press 3 times quickly -> new rand sound

*****/

///////// SKETCH ONLY, not working yet //////
/****

NTMI.kraken.prevButs = 0!10;
NTMI.kraken.prevButs = 0!10;

NTMI.kraken.slotButs = [0, 1, 2, 3];

MFdef.all.keys(Array).sort;

NTMI.nufo.setModeIndex(1);

NTMI.slots.keys(Array);

NTMI.slots.actives.collect(_.isPlaying).selectIndices (_ == true);

MFdef(\randBut).add(\rand, {
	\randBut.postln;
	[
		// switch an active sound
		{
			var nowPlayingIndices = NTMI.slots.actives.collect(_.isPlaying)
			.selectIndices (_ == true);
			var indexToChange = nowPlayingIndices.choose;
			if (indexToChange.notNil) {
				NTMI.slots.chooseNext(indexToChange);
				NTMI.slots.playAt(indexToChange)
			};
		},
		// switch an active preset
		// {
		// 	var nowPlayingIndices = NTMI.slots.actives.collect(_.isPlaying)
		// 	.selectIndices (_ == true);
		// 	var indexToChange = nowPlayingIndices.choose;
		// 	if (indexToChange.notNil) {
		// 		NTMI.slots.keys
		// 		(indexToChange);
		// 		NTMI.slots.playAt(indexToChange)
		//
		// 	},
		// switch influx preset
		// { NTMI.nufo.nUFO.modeStep },
		// switch rand mainFX preset
		{ MFdef(\mainPreStep).value },
	].choose.value;
});

// 2, 4, 7, 9 have ribbons

MFdef(\kr_buts).add(\trig, { |vals|
	vals = vals.keep(8);
	vals.do { |val, i|
		if (val != NTMI.kraken.prevButs[i]) {
			"but % is now %\n".postf(i, val);
			// first four buttons toggle sounds on /off
			if (i < 4) {
				if (val == 0) {
					NTMI.slots.stopAt(i)
				} {
					NTMI.slots.playAt(i)
				};
			} {
				// all other buttons change something randomly
				if (val > 0) { MFdef(\randBut).value }
			};
		};
	};
	NTMI.kraken.prevButs = vals;
});

****/