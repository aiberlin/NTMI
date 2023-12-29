Butz(\DEMO).add(\ntmi_demo, { Tdef(\ntmi_demo).play });
// Butz(\DEMO).add(\nUFO_demo, { Tdef(\nUFO_demo).play });
// Butz(\DEMO).add(\nanoKtl_demo, { Tdef(\nanoKtl_demo).play });
// Butz(\DEMO).add(\flatcat_demo, { Tdef(\nanoKtl_demo).play });


MFdef(\showItems).add(\show, { |names, view, dur = 3|
	defer {
		var preBnds = view.bounds.postln;
		var length = preBnds.height;
		var listBnds = preBnds.moveBy(0, -70).height_(500);
		var listv = ListView(view.parent, listBnds).front
		.font_(NTMI.g.font.copy.size_(18));

		listv.items_(names).value_(view.value);
		defer ({ listv.close }, dur);
		listv
	};
});

Tdef(\wiggleInflux, {
	var inphl = NTMI.inphlux;
	var inNames = inphl.inNames;
	inphl.resetInvals;
	loop {
		var name = inNames.choose;
		inphl.set(name, inphl.get(name) + 0.1.rand2);
		0.1.wait
	}
});


/*
MFdef(\showItems).value(
NdefPreset(\bleepo).getSetNames,
NTMI.g.main.prePops[0]
);
*/

(
Tdef(\ntmi_demo, {

	NTMI.g.setFrontText("***NTMI*** ***DEMO***");
	4.do { |i| 0.1.wait; NTMI.slots.endAt(i) };
	1.wait;

	NTMI.g.setFrontText("Play up to four sounds simultaneously");
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
	NTMI.slots.playAt(0);

	NTMI.g.setFrontText("Each sound has presets - e.g. slot 1:");
	MFdef(\showItems).value(
		NdefPreset(\bleepo).getSetNames,
		NTMI.g.main.prePops[0]
	);
	3.wait;
	6.do { 1.wait; NTMI.pre.stepNdefInf(NTMI.ndefs[0], nil) };

	NTMI.g.setFrontText("See them in detail on the presets gui");
	1.wait;
	defer {
		Butz(\NTMI).run(\presets);
		Window.find(\presets).moveTo(968.0, 190.0);
		NTMI.pre.butAction(0);
	};
	6.do { 1.wait; NTMI.pre.stepNdefInf(NTMI.ndefs[0], 1) };

	NTMI.g.setFrontText("Select the sound processes themselves:");
	6.do {
		1.wait;
		NTMI.slots.stepNext(0);
		NTMI.slots.playAt(0);
		NTMI.pre.butAction(0);
	};

	MFdef(\showItems).value(
		NTMI.slots.choices[0],
		NTMI.g.main.popups[0]
	);
	3.wait;
	6.do {
		1.wait;
		NTMI.slots.stepNext(0);
		NTMI.slots.playAt(0);
		NTMI.pre.butAction(0);
	};

	NTMI.g.setFrontText("For intuitive playing, NTMI uses a metacontrol concept named influx:");
	2.wait;
	defer {
		Butz(\NTMI).run(\inphlux);
		Tdef(\wiggleInflux).play;
	};

	4.wait;

	NTMI.g.setFrontText("Change left side influx inputs by mouse:");
	4.wait;
	NTMI.g.setFrontText("... also works while presets change");
	6.do { 1.wait; NTMI.pre.stepNdefInf(NTMI.ndefs[0], 1) };

	NTMI.g.setFrontText("... also with multiple sounds");
	try { Window.find(\presets).close };
	Butz(\NTMI).run(\slotSounds);
	4.do { |i| 1.wait; NTMI.slots.playAt(i) };

	NTMI.g.setFrontText("and while sounds change\n\n\n\n");
	10.do {
		4.do { |i| 1.wait; NTMI.slots.stepNext(i); NTMI.slots.playAt(i) }
	};
	try { Window.find(\slotSounds).close };


	NTMI.g.setFrontText("Change influx weight presets while playing");
	8.do {
		1.wait;
		NTMI.inph.stepWPre;
	};

	NTMI.g.setFrontText("Choose different main effects: ");
	Butz(\NTMI).run(\mainFX);
	8.do {
		1.wait;
		MFdef.all.mainPreStep.value;
	};

	NTMI.g.setFrontText("Play all of this can from diverse interfaces - see the Butz demo page!");
	2.wait;
	Butz.curr_(\DEMO);

	3.wait;
	Tdef(\wiggleInflux).stop;
	NTMI.ndefs[0].end(5);
	1.wait;
	try { Window.find(\slotSounds).close };
	NTMI.ndefs[1].end(5);
	1.wait;
	try { Window.find(\mainFX).close };
	NTMI.ndefs[2].end(5);
	1.wait;
	try { Window.find(\inphlux).close };
	NTMI.ndefs[3].end(5);

	1.wait;
	NTMI.g.setFrontText("NTMI DEMO done!");
	1.wait;
	NTMI.g.setFrontText("NTMI DEMO");
	1.wait;
	NTMI.g.setFrontText("NTMI");
	1.wait;
	NTMI.g.setFrontText("");
	"*** NTMI DEMO done!".postln
}).clock_(AppClock);
)
