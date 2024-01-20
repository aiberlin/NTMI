/* To Do:
test sections for
randOrb,
binClav,
liveInput,

in separate testdefs:
nUFO, nanoKtl, uc4, ferrari
*/

NTMI.demos = NTMI.demos ? ();
NTMI.demos.notDoneYet = { {
	[
		"... ... not done yet",
		"... not done yet ...",
		"not done yet ... ...",
		"done yet ... ...",
		"yet ... ...",
		"... ...",
		"...", ""
	].do { |str|
		NTMI.g.setFrontText(str);
		1.wait;
	}
} };

Butz(\NTMI_DEMO).clear;
Butz(\NTMI_DEMO).add(\showAll, { Butz.run('Tdef.all') });
Butz(\NTMI_DEMO).add(\Demo_GUI, { Tdef(\NTDemo_GUI).play });
Butz(\NTMI_DEMO).add(\Demo_nanoKtl, { Butz.run('\NTDemo_nanoKtl.all') });
Butz(\NTMI_DEMO).add(\Demo_Presets, { Tdef(\NTDemo_Presets, NTMI.demos.notDoneYet).play });

Butz(\NTMI_DEMO).add(\Demo_Influx, { Tdef(\NTDemo_Influx, NTMI.demos.notDoneYet).play });
Butz(\NTMI_DEMO).add(\Demo_MainFX, { Tdef(\NTDemo_MainFX, NTMI.demos.notDoneYet).play });
Butz(\NTMI_DEMO).add(\Demo_flatcat, { Tdef(\NTDemo_flatcat, NTMI.demos.notDoneYet).play });

Butz(\NTMI_DEMO).add(\NT_codeTest, { Tdef(\NT_codeTest).play });


MFdef(\showPopItems).add(\show, { |names, view, dur = 3|
	defer {
		var preBnds = view.bounds.postln;
		var length = preBnds.height;
		var listBnds = preBnds.moveBy(0, -70).height_(500);
		var listv = ListView(view.parent, listBnds).front
		.font_(NTMI.g.font);

		listv.items_(names).value_(view.value);
		defer ({ listv.close }, dur);
		listv
	};
});

/*
MFdef(\showPopItems).value(
	NdefPreset(\bleepo).getSetNames,
	NTMI.g.main.prePops[0]
);
Tdef(\NT_codeTest).stop.play;
Tdef(\NT_codeTest).stop;
*/

(
Tdef(\NT_codeTest, {

	"\n\n*** Tdef('NT_codeTest') starts!\n\n".postln;
	Butz(\NTMI).run(\Main_NTMI);
	NTMI.g.setFrontText("***NT_codeTest***");
	4.do { |i| 0.1.wait; NTMI.slots.endAt(i) };
	1.wait;

	NTMI.g.setFrontText("Play four sounds");
	4.do { |i| 1.wait; NTMI.slots.playAt(i) };
	1.wait;

	NTMI.g.setFrontText("...and change their volumes...");
	8.do { |i| 0.5.wait; NTMI.ndefs.wrapAt(i).vol_(exprand(0.05, 0.5)) };
	1.wait;

	NTMI.g.setFrontText("... and change main volume ...");
	4.do { |i| 0.5.wait; MFdef(\mainVol).(exprand(0.25, 0.5)) };
	1.wait;
	MFdef(\mainVol).(1);

	(1..3).do { |i| NTMI.slots.endAt(i) };
	4.do { |i| NTMI.ndefs.wrapAt(i).vol_(0.25) };
	NTMI.slots.playAt(0);

	Butz.curr = \NTMI_DEMO;

	NTMI.g.setFrontText("Change presets on slot 1:");
	defer {
		Butz(\NTMI).run(\presets);
		Window.find(\presets).moveTo(968.0, 100.0);
		NTMI.pre.butAction(0);
	};
	6.do { 1.wait; NTMI.pre.stepNdefInf(NTMI.ndefs[0], nil) };

	NTMI.g.setFrontText("Select sound processes:");
	2.do {
		1.wait;
		NTMI.slots.stepNext(0); NTMI.slots.playAt(0);
		NTMI.pre.stepNextInf(NTMI.ndefs[0]);
		NTMI.pre.butAction(0);
	};

	NTMI.g.setFrontText("Show and simulate Influx");
	2.wait;
	defer {
		Butz(\NTMI).run(\inphlux);
		NTMI.inph.wiggle.play;
	};

	2.wait;

	NTMI.g.setFrontText("Change influx inputs");
	4.wait;
	NTMI.g.setFrontText("... while presets change");
	6.do { 1.wait; NTMI.pre.stepNdefInf(NTMI.ndefs[0], 1) };

	NTMI.g.setFrontText("... and with multiple sounds\n\n\n");
	NTMI.close(\presets);
	Butz(\NTMI).run(\slotSounds);
	4.do { |i| 1.wait; NTMI.slots.playAt(i) };

	NTMI.g.setFrontText("... and while sounds change\n\n\n\n");
	10.do {
		4.do { |i|
			1.wait;
			NTMI.slots.stepNext(i);
			NTMI.slots.playAt(i);
			NTMI.pre.stepNextInf(NTMI.ndefs[i]);
		}
	};
	NTMI.close(\slotSounds);

	3.wait;
	NTMI.g.setFrontText("Change influx weight presets");
	8.do {
		1.wait;
		NTMI.inph.stepWPre;
	};
	1.wait;
	NTMI.inph.setWPreIndex(0);

	3.wait;
	NTMI.g.setFrontText("Change main effects");
	Butz(\NTMI_DEMO).run(\mainFX);
	8.do {
		1.wait;
		MFdef.all.mainPreStep.value;
	};
	NTMI.inph.wiggle.stop;
	NTMI.close(\slotSounds);
	NTMI.close(\inphlux);
	NTMI.close(\mainFX);

	NTMI.ndefs.do(_.end(1));
	1.wait;
	NTMI.g.setFrontText("NT_codeTest done!");
	3.wait;
	NTMI.g.setFrontText("");
}).clock_(AppClock);
);
