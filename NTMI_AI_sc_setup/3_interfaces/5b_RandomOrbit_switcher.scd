// RandomOrbit chordal keyboard example:
//
// 6 keys with two states - this is the maximum for macOS keyboards
// - if pressed within chordTime, the bits accumulate, then fire as one change
// - if all released to 0 within chordTime, the chord number before releases is held

/// for nufo, update to 8 pads
/// make sure pads release fast enough and evenly enough
/// so that holding last random chord works!


(
NTMI.ro = NTMI.ro ? ();
NTMI.ro.bits = 0 ! 6;
NTMI.ro.letterKeys = "weruio"; // macOS only allows 6 keys at the same time
NTMI.ro.powers = [1, 2, 4, 8, 16, 32];
NTMI.ro.num = { |ro| (ro.powers * ro.bits).sum };
NTMI.ro.firstval = 1;
NTMI.ro.collecting = false;
NTMI.ro.lastval = 1;
NTMI.ro.str = { |ro| NTMI.ro.bits.join + "->" + NTMI.ro.num };

NTMI.ro.chordTime = 0.03;
NTMI.ro.font = Font(Font.defaultMonoFace, 21);
NTMI.ro.bigFont = Font(Font.defaultMonoFace, 34);

NTMI.ro.getPressed = { |dict, index, value|
	if (NTMI.ro.collecting.not) {
		"collecting ...".postln;
		NTMI.ro.firstval = NTMI.ro.num;
		NTMI.ro.collecting = true;
		defer { NTMI.ro.uv.refresh };
	};
	NTMI.ro.bits[index] = value;
	// use Tdef to unschedule if already
	NTMI.ro.endTask.stop.play;
};


NTMI.ro.endTask = TaskProxy({
	NTMI.ro.chordTime.wait;
	NTMI.bin.randOrb(NTMI.ro.num);

	NTMI.ro.lastval = if (NTMI.ro.num == 0, NTMI.ro.firstval, NTMI.ro.num);
	defer { NTMI.ro.uv.refresh };
	NTMI.ro.collecting = false;
}).quant_(0);

NTMI.ro.letterKeys.do { |char, i|
	KeyPlayer(\ro).putDown(char, { |char| NTMI.ro.getPressed(i, 1) }, noRep: true);
	KeyPlayer(\ro).putUp(char, { |char| NTMI.ro.getPressed(i, 0) });
};
)
