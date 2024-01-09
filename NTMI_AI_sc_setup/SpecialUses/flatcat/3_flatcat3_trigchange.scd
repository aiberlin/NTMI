/** ToDo :

after change triggered, wait a bit before retrig
**/

NTMI.flatcat = NTMI.flatcat ? ();

NTMI.flatcat.changeData = 0!200;
NTMI.flatcat.changeIndex = 0;
NTMI.flatcat.changeThresh = 0.2;
NTMI.flatcat.changeMinTime = 5;
NTMI.flatcat.changeLastTime = 0;

NTMI.flatcat.changeThresh = 0.2;

(
NTMI.flatcat[\onData].add(\meta, {
	NTMI.flatcat.use {
		var canChange = (Main.elapsedTime - ~changeLastTime > ~changeMinTime);
		var change = MKtl(\flatcat).elAt.sum { |el|
			(el.value - el.prevValue).abs
		};

		~changeData.put(~changeIndex, change);
		~changeIndex = (~changeIndex + 1) mod: ~changeData.size;

		if (change > ~changeThresh and: canChange) {
			var slotIndex = 4.rand;
			var ndef = NTMI.ndefs[slotIndex];
			var preset = NdefPreset(ndef);

			~changeLastTime = Main.elapsedTime;

			"*** flatcat change: ".postln;
			if (0.5.coin) {
				"*** new sound: ".post;
				NTMI.slots.stepNext(slotIndex);
				defer { NTMI.slots.playAt(slotIndex) };
				NTMI.ndefs[slotIndex].postln;
			};
			if (0.1.coin) {
				"*** new mainFX: ".post;
				MFdef(\mainPreStep).value;
			};

			NTMI.pre.stepNdefInf(ndef);
		};
	};
});
)
