/**
when flatcat makes unusually big moves,
trigger several possible layers of change:
- new presets on the sounds
- new sounds
- new mainfx presets
- optionally, add function to onData to trigger when big change.

ToDo:
maybe split into separate functions for tracking and triggering?

Tune:
// trig func by hand
NTMI.flatcat.onData.value;
// see change profile for last 10 secs
NTMI.flatcat.changeData.plot;

NTMI.flatcat[\onData].activeNames;

**/

// internal data
NTMI.flatcat = NTMI.flatcat ? ();
NTMI.flatcat.changeData = 0!200;
NTMI.flatcat.changeIndex = 0;
NTMI.flatcat.changeLastTime = 0;

// tunable settings:
NTMI.flatcat.changeThresh = 0.2;
NTMI.flatcat.changeMinTime = 5;
NTMI.flatcat.newSndProb = 0.2;
NTMI.flatcat.newMfxProb = 0.1;


(
NTMI.flatcat[\onData].add(\meta, {
	var fc = NTMI.flatcat;
	var now = Main.elapsedTime.round(0.01);
	var timeSinceLastChange = now - fc.changeLastTime;
	var canChangeTime = timeSinceLastChange > fc.changeMinTime;
	var changeSum = MKtl(\flatcat).elAt.sum { |el|
		(el.value - el.prevValue).abs
	}.round(0.001);

	var canChangeDiff = changeSum > fc.changeThresh;

	////// debug:
	// "now: % lastTime: %  diff: ".postf(now, fc.changeLastTime, now - fc.changeLastTime);
	// "%\n".postf((now - fc.changeLastTime).round(0.01));
	// "*** timeOK: %\n".postf(canChangeTime);
	//
	// "change: % > %: %\n".postf(changeSum, fc.changeThresh, canChangeDiff);

	fc.changeData.put(fc.changeIndex, changeSum);
	fc.changeIndex = (fc.changeIndex + 1) mod: fc.changeData.size;

	// store it so later funcs can use it:
	fc.doChange = canChangeTime and: canChangeDiff;

	if (fc.doChange) {
		var slotIndex = 4.rand;
		var ndef = NTMI.ndefs[slotIndex];
		var preset = NdefPreset(ndef);

		fc.changeLastTime = now;

		"*** flatcat changes: ".postln;
		"timeSinceLastChange: %\n".postf(timeSinceLastChange.round(0.01));
		"sum % > %: %\n".postf(changeSum, fc.changeThresh, canChangeDiff);

		if (fc.newSndProb.coin or: (NTMI.slots.nowPlaying.size < 1)) {
			"*** new sound: ".post;
			NTMI.slots.stepNext(slotIndex);
			defer { NTMI.slots.playAt(slotIndex) };
			NTMI.ndefs[slotIndex].postln;
		};
		if (fc.newMfxProb.coin) {
			"*** new mainFX: ".post;
			MFdef(\mainPreStep).value;
		};
		// preset always changes
		NTMI.pre.stepNdefInf(ndef);
	};
	\meta
});
)
