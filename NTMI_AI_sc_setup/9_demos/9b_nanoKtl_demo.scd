Butz(\NTMI_DEMO).add(\Demo_nanoKtl, { Tdef(\Demo_nanoKtl).play });

Tdef(\Demo_nanoKtl).stop.play;

/*
Tdef(\Demo_nanoKtl).stop.play;
Tdef(\Demo_nanoKtl).stop;
*/
(
Tdef(\Demo_nanoKtl, {
	var myname = \Demo_nanoKtl;

	Butz(\NTMI).run(\Main_NTMI);
	m = MKtl(\nanoKtl);
	m.elAt(\vols).value = NTMI.ndefs.collect(_.vol);
	m.elAt(\inflSet).value = 0.5;


	4.do { |i| 0.1.wait; NTMI.slots.endAt(i) };
	"\n\n*** Tdef('%') starts!\n\n".postf(myname);
	NTMI.g.setFrontText("***NTMI*** ***Demo*** **nanoKtl**");
	3.wait;


	NTMI.g.setFrontText("open Butz -> interfaces, and click on nanoKtl");
	Butz.curr = \interfaces;
	1.wait;
	Butz.butz.detect { |bt| bt.states[0][0] == \nanoKtl }.doAction;
	1.wait;


	NTMI.g.setFrontText("On the nanoKtl (or its gui), click the 4 snd play buttons");
	m.elAt(\playBts).do { |bt, i|
		0.5.wait; bt.valueAction_(1);
		0.5.wait; bt.value_(0)
	};
	1.wait;

	NTMI.g.setFrontText("On the nanoKtl (or its gui), turn the left 4 knobs to set volume");
	4.do {
		m.elAt(\vols).do { |kn, i|
			1.wait;
			kn.valueAction = kn.value + [0.2, 0.1, -0.1, -0.2].choose;
		}
	};
	1.wait;

	NTMI.g.setFrontText("Use rightmost slider to set main volume");
	4.do { |i|
		0.5.wait;
		m.elAt(\main).valueAction_(exprand(0.25, 1))
	};
	1.wait;
	m.elAt(\main).valueAction_(0.5);

	4.do { |i| NTMI.ndefs.wrapAt(i).vol_(0.25) };
	(1..3).do { |i| NTMI.slots.endAt(i) };
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
			1.wait;
			kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
		};
	};

	NTMI.g.setFrontText("Or all 4 on the slotSounds gui");
	Butz(\NTMI).run(\slotSounds);
	Window.find(\presets).close;
	m.elAt(\playBts).do { |bt, i|
		0.5.wait; bt.valueAction_(1);
		0.5.wait; bt.value_(0)
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
	2.do {
		m.elAt(\select).do { |kn, i|
			m.elAt(\selMode)[i].valueAction_(1);
			0.5.wait; kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
			0.5.wait; m.elAt(\selMode)[i].valueAction_(0);
			0.5.wait; m.elAt(\playBts)[i].valueAction_(1);
			0.5.wait; m.elAt(\playBts)[i].valueAction_(0);
		};
	};


	NTMI.g.setFrontText("Influx - the NTMI concept for intuitive playing:");
	defer {
		Butz(\NTMI).run(\inphlux);
		NTMI.inphlux.resetInvals;
		NTMI.inph.wiggle.stop;
	};
	2.wait;


	NTMI.g.setFrontText("Change influx inputs with all sliders:");

	fork {
		m.elAt(\inflSet).do { |sl|
			5.do { 0.2.wait; sl.valueAction = sl.value + 0.2.rand2 };
		};
	};

	NTMI.g.setFrontText("... also works while presets change");
	fork {
		m.elAt(\inflSet).do { |sl|
			5.do { 0.2.wait; sl.valueAction = sl.value + 0.2.rand2 };
		};
	};
	2.do {
		m.elAt(\select).do { |kn|
			1.wait;
			kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
		};
	};

	NTMI.g.setFrontText("... also with multiple sounds\n\n\n");
	NTMI.close(\presets);
	Butz(\NTMI).run(\slotSounds);
	4.do { |i| 1.wait; NTMI.slots.playAt(i) };

	NTMI.g.setFrontText("and while sounds change\n\n\n\n");
	4.do {
		2.do {
			m.elAt(\select).do { |kn, i|
				m.elAt(\selMode)[i].valueAction_(1);
				0.5.wait; kn.deviceValueAction = kn.deviceValue + rrand(1, 4);
				0.5.wait; m.elAt(\selMode)[i].valueAction_(0);
				0.5.wait; m.elAt(\playBts)[i].valueAction_(1);
				0.5.wait; m.elAt(\playBts)[i].valueAction_(0);
			};
		};
	};
	NTMI.close(\slotSounds);

	2.wait;
	NTMI.g.setFrontText("Change influx weight presets with left transport buttons");
	8.do {
		0.5.wait; m.elAt(\next_inph).valueAction_(1);
		0.5.wait; m.elAt(\next_inph).value_(0);
		0.5.wait; m.elAt(\rand_inph).valueAction_(1);
		0.5.wait; m.elAt(\rand_inph).value_(0);
		0.5.wait; m.elAt(\prev_inph).valueAction_(1);
		0.5.wait; m.elAt(\prev_inph).value_(0);
	};
	1.wait;
	NTMI.inph.setWPreIndex(0);


	3.wait;
	NTMI.g.setFrontText("Choose from various main effects: ");
	Butz(\NTMI).run(\mainFX);
	8.do {
		0.5.wait; m.elAt(\next_pre).valueAction_(1);
		0.5.wait; m.elAt(\next_pre).value_(0);
		0.5.wait; m.elAt(\rand_pre).valueAction_(1);
		0.5.wait; m.elAt(\rand_pre).value_(0);
		0.5.wait; m.elAt(\prev_pre).valueAction_(1);
		0.5.wait; m.elAt(\prev_pre).value_(0);
	};


	NTMI.g.setFrontText("NTMI DEMO done!");
	NTMI.inph.wiggle.stop;
	1.wait;
	NTMI.ndefs[0].end(5); NTMI.close(\slotSounds);
	1.wait;
	NTMI.ndefs[1].end(5); NTMI.close(\mainFX);
	1.wait;
	NTMI.ndefs[2].end(5); NTMI.close(\inphlux);
	1.wait;
	NTMI.ndefs[3].end(5);

	1.wait;
	NTMI.g.setFrontText("NTMI DEMO ...");
	1.wait;
	NTMI.g.setFrontText("NTMI ...");
	1.wait;
	NTMI.g.setFrontText("...");

	"*** nanoKtl DEMO done!".postln
}).clock_(AppClock);
)
