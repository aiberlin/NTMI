/********

With modal buttons, tests are confused ...
q.osc.leftDown.clear; q.osc.rightDown.clear;

**********/

Tdef('zz_tests', {
	~postOK = false;
	~failCount = 0;
	~testCount = 0;

	t = { |func, failmess, passmess, dt = 0.1|
		~testCount = ~testCount + 1;
		if (func.value) {

			if (~postOK) { (passmess ? "").postln };
		} {
			~failCount = ~failCount + 1;
			"*** FAIL: % \n".postf(failmess);
			"code: % \n".postf(func.cs);
			try { dt.wait };
		};
	};

	"Tdef('zz_tests') runs.".postln;

	q.osc.leftDown.clear; q.osc.rightDown.clear;

	"--- GENERAL SANITY ---".postln;
	// Tdef('xoscSim').stop;
	t.({ s.serverRunning }, "server not running.", "server ok.");
	t.({ MKtl.all[\xosc].notNil }, "xosc not present.", "xosc ok.");
	t.({ MKtl.all['nanoKtl'].notNil }, "nanoKtl not present.", "nanoKtl ok.");
	t.({ MainFX.all[s.name].notNil }, "MainFX missing.", "MainFX ok.");
	t.({ q.inphlux.isKindOf(Influx) }, "q.inphlux not OK.", "inphlux ok.");

	t.({ q.process.allNames.size >= 15 }, "less than 15 sounds?", "sounds ok.");
	t.({ q.osc.timeSinceLast < 1.0 }, "xosc not sending.", "xosc ok.");

	"\n --- SLOTS ---".postln;
	t.({ q.slots.actives.size == 4 }, "q.slots.actives have wrong size", "4 slots ok.");
	t.({ q.slots.test }, "q.slots and choices are wrong", "slots and choices ok.");

	t.({
		var prevSlots = q.slots.actives.copy;
		q.slots.addActive(4, Ndef(q.slots.choices[0].choose));
		prevSlots == prevSlots
	}, "q.slots.addActive failed to protect for index", "q.slots.addActive ok.");

	t.({
		var prevSlots = q.slots.actives.copy;
		q.slots.addActive(0, (key: \xyz));
		prevSlots == prevSlots
	}, "q.slots.addActive failed to protect for illegal obj", "q.slots.addActive ok.");

	t.({
		var index = 0;
		var prevSlots = q.slots.actives.copy.postcs;
		var choices = q.slots.choices[index].copy;
		choices.remove(q.slots.actives[index].key);
		q.slots.addActive(0, p[choices.choose.postln]);
		q.slots.actives.postcs;
		prevSlots[0] != q.slots.actives[0];
	}, "q.slots.addActive failed to change ndef", "q.slots.addActive changed ok.");


	"\n --- XOSC Play/Stop BUTTONS ---".postln;
	2.do {
		var oldFadetime = q.slots.fadeoutTime;
		q.slots.fadeoutTime = 0.01;

		q.slots.actives.do { |ndef, i|
			t.({
				var wasPlaying = ndef.monitor.isPlaying;
				x.elAt(\sw, i).valueAction_(1);
				0.1.wait;
				ndef.monitor.isPlaying != wasPlaying;
			}, "xosc on/off button failed", "xosc on/off buttons OK.");
		};
		q.slots.fadeoutTime = oldFadetime;
		q.osc.leftDown.clear; q.osc.rightDown.clear;
	};

	"\n --- XOSC MODE BUTTON ---".postln;
	t.({
		var prevMode = q.inph.mode;
		x.elAt(\sw, \5).valueAction_(1);
		x.elAt(\sw, \5).valueAction_(0);
		prevMode != q.inph.mode;
	}, "xosc mode switch broken", "xosc mode but OK.");

	// and toggle back
	t.({
		var prevMode = q.inph.mode;
		x.elAt(\sw, 4).valueAction_(1);
		x.elAt(\sw, 4).valueAction_(0);
		prevMode != q.inph.mode;
	}, "xosc mode switch broken", "xosc mode but OK.");

	"\n --- XOSC preset step BUTTONS ---".postln;
	// buttons 6 and 7 step ndef presets and inphlux weights presets down/up
	t.({
		var slotIndex = 1;
		var presetToTest = NdefPreset(q.ndefs[slotIndex]);
		var prevNdefPreIndex = presetToTest.currIndex;
		q.slots.playAt(slotIndex);
		0.15.wait;
		x.elAt(\sw, \6).valueAction_(0);
		0.15.wait;
		q.slots.stopAt(slotIndex);
		x.elAt(\sw, \6).valueAction_(1);
		q.osc.leftDown.clear; q.osc.rightDown.clear;

		prevNdefPreIndex != presetToTest.currIndex;
	}, "xosc ndef preset switch not working", "xosc preset but OK.");

	t.({
		var slotIndex = 3;
		var presetToTest = NdefPreset(q.ndefs[slotIndex]);
		var prevNdefPreIndex = presetToTest.currIndex;
		q.slots.playAt(slotIndex);
		0.15.wait;
		x.elAt(\sw, \7).valueAction_(0);
		0.15.wait;
		q.slots.stopAt(slotIndex);
		x.elAt(\sw, \7).valueAction_(1);
		q.osc.leftDown.clear; q.osc.rightDown.clear;

		prevNdefPreIndex != presetToTest.currIndex;
	}, "xosc ndef preset switch not working", "xosc preset but OK.");

	0.2.wait;

	// buttons 6 and 7 step ndef presets and inphlux weights presets down/up
	t.({
		var prevInphWeightsKey = q.inphlux.presets.findKeyForValue(q.inphlux.weights);
		var postSwitchKey;
		x.elAt(\sw, \7).valueAction_(0);
		0.02.wait;
		postSwitchKey = q.inphlux.presets.findKeyForValue(q.inphlux.weights);
		x.elAt(\sw, \7).valueAction_(1);
		"prev key: % new key: %\n".postf(prevInphWeightsKey, postSwitchKey);
		prevInphWeightsKey != postSwitchKey;
	}, "xosc influx preset switch not working", "xosc preset but OK.");



	"\n --- XOSC modal BUTTONS ---".postln;

	// hold preUp button, press a slsot button:
	/// volume on that slot goes up,
	/// play state stays the same
	t.({
		var dt = 0.2;
		var slot = 3;
		var snd = q.ndefs[slot];
		var playState = snd.monitor.isPlaying;
		var oldvol = snd.vol;
		[playState, oldvol].postln;

		dt.wait;
		// hold down a slot button
		x.elAt(\sw, slot).valueAction_(0);
		// press / release preUp
		dt.wait;
		x.elAt(\sw, 5).valueAction_(1);
		dt.wait;
		x.elAt(\sw, 5).valueAction_(0);
		dt.wait;
		x.elAt(\sw, slot).valueAction_(0);
		dt.wait;
		(snd.vol.postln > oldvol).postln and:

		(playState == snd.monitor.isPlaying).postln;
	}, "modal volume UP failed!", "modal volume UP OK.");

	// hold preDown button, press a slsot button:
	/// volume on that slot goes down,
	/// play state stays the same
	t.({
		var dt = 0.2;
		var slot = 3;
		var snd = q.ndefs[slot];
		var playState = snd.monitor.isPlaying;
		var oldvol = snd.vol;
		[playState, oldvol].postln;

		dt.wait;
		// hold down a slot button
		x.elAt(\sw, slot).valueAction_(0);
		// press / release preUp
		dt.wait;
		x.elAt(\sw, 6).valueAction_(1);
		dt.wait;
		x.elAt(\sw, 6).valueAction_(0);
		dt.wait;
		x.elAt(\sw, slot).valueAction_(0);
		dt.wait;

		(snd.vol.postln < oldvol).postln and:
		(playState == snd.monitor.isPlaying).postln;
	}, "modal volume DOWN failed!", "modal volume DOWN OK.");


	"\n\n*** NTMI TESTS DONE: % tests with % failures.\n\n".postf(~testCount, ~failCount);
}).stop.play;
