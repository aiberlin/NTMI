/*

~waitX = Wait(10, 0.1, 10, doPost: true, label: \X);
~waitX .dump

(
~waitX.time = 10;
~task = Task {
	~waitX.dump;
	\before.postln;
	~waitX.wait;
	\after.postln;
};
)
~task.play;

// after 5 seconds
~waitX.time = 0; // stop asap

// reset wait time while waiting
~waitX.time = 12;

// immediate stop:
~waitX.time = 0;

// set a checkFunc:
(
a = 20;
~waitX.checkFunc = { |wait|
	"check: ".post; (a < 10).postln;
};
~waitX.time = 12;

~task.reset.play;
)
// an observed condition changes,
// checkFunc is now true: ~waitX stops.
a = 6;

// test random early stop:
~waitX.time = 12;
~waitX.checkFunc = { 0.01.coin };
~task.reset.play;

*/

Wait {
	var <>time, <>dt, <>countDown, <>checkFunc, <>doPost = false, <>label = \anon;

	*new { |time, dt = 0.1, countDown = 10, checkFunc, doPost, label|
		^super.newCopyArgs(time, dt, countDown, checkFunc, doPost, label);
	}

	wait {
		var offgrid = 0, i = 0;
		var check;

		this.postInfo("starts");
		while {
			check = checkFunc.value;
			offgrid = time % dt;
			// align with dt-grid first
			if (offgrid > 0) { offgrid.wait };
			time > 0.0001 and: (check != true)
		} {
			i = i + 1;
			dt.wait;
			time = time - dt;
			if (i % countDown == 0) {
				this.postInfo(time.round(0.01).cs + "secs to go");
			}
		};
		this.postInfo("done.");
	}

	postInfo { |str|
		if (doPost) { "Wait %: %\n".postf(label, str) }
	}
}

