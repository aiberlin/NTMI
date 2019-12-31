// RandomOrbit chordal keyboard example:
//
// 6 keys with two states - this is the maximum for macOS keyboards
// - if pressed within chordTime, the bits accumulate, then fire as one change
// - if all released to 0 within chordTime, the chord number before releases is held

/// for nufo, update to 8 pads
/// make sure pads release fast enough and evenly enough
/// so that holding last random chord works!


(
q = q ? ();
q.ro = q.ro ? ();
q.ro.bits = 0 ! 6;
q.ro.letterKeys = "weruio"; // macOS only allows 6 keys at the same time
q.ro.powers = [1, 2, 4, 8, 16, 32];
q.ro.num = { |ro| (ro.powers * ro.bits).sum };
q.ro.firstval = 1;
q.ro.collecting = false;
q.ro.lastval = 1;
q.ro.str = { |ro| q.ro.bits.join + "->" + q.ro.num };

q.ro.chordTime = 0.03;
q.ro.fire = false;
q.ro.font = Font(Font.defaultMonoFace, 21);
q.ro.bigFont = Font(Font.defaultMonoFace, 34);

MFdef(\ro).add(\collect, { |index, value|
	if (q.ro.collecting.not) {
		// "collecting ...".postln;
		q.ro.firstval = q.ro.num;
		q.ro.collecting = true;
		defer { q.ro.uv.refresh };
	};
	q.ro.bits[index] = value;
	// use Tdef to unschedule if already
	q.ro.endTask.stop.play;
});

MFdef(\fire).add(\post, { "ok, fire!\n".postln });
MFdef(\fire).add(\fire, { MFdef(\randOrb).value(q.ro.num) });
MFdef(\fire).disable(\post);

q.ro.endTask = TaskProxy({
	q.ro.chordTime.wait;
	MFdef(\fire).value;
	q.ro.lastval = if (q.ro.num == 0, q.ro.firstval, q.ro.num);
	defer { q.ro.uv.refresh };
	q.ro.collecting = false;
}).quant_(0);

q.ro.letterKeys.do { |char, i|
	KeyPlayer(\ro).putDown(char, { |char| MFdef(\ro).(i, 1) }, noRep: true);
	KeyPlayer(\ro).putUp(char, { |char| MFdef(\ro).(i, 0) });
};
)
