Butz(\DEMO).add(\NTMI_nanoKtl, { Tdef(\NTMI_nanoKtl).play });

/*
Tdef(\NTMI_nanoKtl).stop.play;
Tdef(\NTMI_nanoKtl).stop;
*/
(
Tdef(\NTMI_nanoKtl, {
	m = MKtl(\nanoKtl);
	m.elAt(\vols).value = 0.5;

	4.do { |i| 0.1.wait; NTMI.slots.endAt(i) };
	"\n\n*** Tdef('nanoKtl_demo') starts!\n\n".postln;
	NTMI.g.setFrontText("***NTMI*** ***DEMO*** **nanoKtl**");

	// 3.wait;
	// NTMI.g.setFrontText("open Butz -> interfaces, and click on nanoKtl");
	// 1.wait;
	// Butz.curr = \interfaces;
	// 1.wait;
	// Butz.butz.detect { |bt| bt.states[0][0] == \nanoKtl }.doAction;
	// 2.wait;

	NTMI.g.setFrontText("On the nanoKtl (or its gui), click the 4 snd play buttons");
	m.elAt(\playBts).do { |bt, i| 1.wait; bt.valueAction_(1); 1.wait; bt.value_(0) };
	1.wait;

	// NTMI.g.setFrontText("On the nanoKtl (or its gui), turn the left 4 knobs to set volume");
	// m.elAt(\vols).value = NTMI.ndefs.collect(_.vol);
	//
	// 4.do {
	// 	m.elAt(\vols).do { |kn, i|
	// 		1.wait;
	// 		kn.valueAction = kn.value + [0.05, -0.05].choose;
	// 	}
	// };
	// 1.wait;
	//
	// NTMI.g.setFrontText("Use rightmost slider to set main volume");
	// 4.do { |i| 0.5.wait;
	// 	m.elAt(\main).valueAction_(exprand(0.25, 1))
	// };
	// 1.wait;
	// MFdef(\mainVol).(1);

	(1..3).do { |i| NTMI.slots.endAt(i) };
	4.do { |i| NTMI.ndefs.wrapAt(i).vol_(0.25) };
	0.2.wait;
	NTMI.slots.playAt(0);

	Butz.curr = \NTMI;


	NTMI.g.setFrontText("To change presets, use knobs 5-8:");
	3.wait;
	m.elAt(\select).do { |kn|
		kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
		1.wait;
	};

	NTMI.g.setFrontText("See them in detail on the presets gui");
	1.wait;

	Butz(\NTMI).run(\presets);
	Window.find(\presets).moveTo(968.0, 100.0);
	NTMI.pre.butAction(0);
	2.do {
		m.elAt(\select).do { |kn|
			kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
			1.wait;
		};
	};

	NTMI.g.setFrontText("Or all 4 on the slotSounds gui");
	Butz(\NTMI).run(\slotSounds);
	Window.find(\presets).close;
	m.elAt(\playBts).do { |bt, i|
		1.wait; bt.valueAction_(1); 1.wait; bt.value_(0)
	};
	2.do {
		m.elAt(\select).do { |kn|
			kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
			1.wait;
		};
	};


	NTMI.g.setFrontText("To select a new sound process,"
		"hold e.g. the R button 5, then turn knob 5"
	);

	3.do {
		m.elAt(\select).do { |kn, i|
			m.elAt(\selMode)[i].valueAction_(1);
			0.5.wait;
			kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
			0.5.wait;
			m.elAt(\selMode)[i].valueAction_(0);
			0.5.wait;
			m.elAt(\playBts)[i].valueAction_(1);
			0.5.wait;
			m.elAt(\playBts)[i].valueAction_(0);

		};
	};

	NTMI.g.setFrontText("Influx - the NTMI concept for intuitive playing:");
	2.wait;
	defer {
		Butz(\NTMI).run(\inphlux);
		Tdef(\wiggleNanoKtl).play;
	};

	// 4.wait;
	//
	// NTMI.g.setFrontText("Change left side influx inputs by mouse:");
	// 4.wait;
	// NTMI.g.setFrontText("... also works while presets change");
	// 6.do { 1.wait; NTMI.pre.stepNdefInf(NTMI.ndefs[0], 1) };
	//
	// NTMI.g.setFrontText("... also with multiple sounds\n\n\n");
	// try { Window.find(\presets).close };
	// Butz(\NTMI).run(\slotSounds);
	// 4.do { |i| 1.wait; NTMI.slots.playAt(i) };
	//
	// NTMI.g.setFrontText("and while sounds change\n\n\n\n");
	// 10.do {
	// 	4.do { |i|
	// 		1.wait;
	// 		NTMI.slots.stepNext(i);
	// 		NTMI.slots.playAt(i);
	// 		NTMI.pre.stepNextInf(NTMI.ndefs[i]);
	// 	}
	// };
	// try { Window.find(\slotSounds).close };
	//
	// 3.wait;
	// NTMI.g.setFrontText("Change influx weight presets while playing");
	// 8.do {
	// 	1.wait;
	// 	NTMI.inph.stepWPre;
	// };
	// 1.wait;
	// NTMI.inph.setWPreIndex(0);
	//
	// 3.wait;
	// NTMI.g.setFrontText("Choose from various main effects: ");
	// Butz(\NTMI).run(\mainFX);
	// 8.do {
	// 	1.wait;
	// 	MFdef.all.mainPreStep.value;
	// };
	//
	// NTMI.g.setFrontText("Play all these from diverse interfaces - see the Butz demo page!");
	// 2.wait;
	// Butz.curr_(\DEMO);
	//
	//
	// 3.wait;
	// Tdef(\wiggleInflux).stop;
	// NTMI.ndefs[0].end(5);
	// 1.wait;
	// try { Window.find(\slotSounds).close };
	// NTMI.ndefs[1].end(5);
	// 1.wait;
	// try { Window.find(\mainFX).close };
	// NTMI.ndefs[2].end(5);
	// 1.wait;
	// try { Window.find(\inphlux).close };
	// NTMI.ndefs[3].end(5);
	//
	// 1.wait;
	// NTMI.g.setFrontText("NTMI DEMO done!");
	// 1.wait;
	// NTMI.g.setFrontText("NTMI DEMO");
	// 1.wait;
	// NTMI.g.setFrontText("NTMI");
	// 1.wait;
	// NTMI.g.setFrontText("");
	"*** nanoKtl DEMO done!".postln
}).clock_(AppClock).play;
)
