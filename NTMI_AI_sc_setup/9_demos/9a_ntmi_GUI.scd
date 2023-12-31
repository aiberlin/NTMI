/**** Test all GUI actions

// this is in 9_ntmi_general.scd :
MFdef(\showPopItems).value(
NdefPreset(\bleepo).getSetNames,
NTMI.g.main.prePops[0]
);

NTMI.g.main.skeys.cs
[ 'backCol', 'bigUV', 'bigUVBounds', 'bigUVMFunc', 'caliBut', 'clockZone', 'coupleButs', 'frontText', 'fxZone', 'imuFunc', 'imuUV', 'imuUVBounds', 'imuUVMFunc', 'leftMVZone', 'mainSl', 'mainVolZone', 'meter', 'meterCenterTop', 'meterLeft', 'meterWidth', 'mfxBut', 'movevals', 'ndefMViews', 'nufoView', 'nufoViews', 'nufoZone', 'padCols', 'popups', 'prePops', 'rMViews', 'recBut', 'recZone', 'rightColumn', 'skipper', 'sliderCols', 'snapBounds', 'snapBut', 'stetho', 'updateMainVol', 'updateSlots', 'w', 'winUpdate' ]

*/

(
Tdef(\NTDemo_GUI, {
	var myTdef = Tdef(\NTDemo_GUI);
	var myName = myTdef.key;
	var playInfluxByMouse;

	"\n\n*** Tdef('%') starts!\n\n".postf(myName);
	NTMI.ndefs.do(_.end);
	NTMI.ndefs.do(_.vol_(0.25));
	Window.closeAll;
	Butz(\NTMI).run(\Main_NTMI);
	0.2.wait;
	NTMI.g.setFrontText("***NTMI*** ***Demo*** ***GUI***");
	2.wait;


	NTMI.g.setFrontText("Click on left views to play up to four sounds");
	NTMI.g.main.ndefMViews.do { |view|
		view.uv.mouseDown (10, 10);
		0.5.wait;
		view.uv.mouseUp(10, 10);
		0.5.wait;
	};

	NTMI.g.setFrontText("click and drag to change their volumes");

	NTMI.g.main.ndefMViews.do { |view|
		var x = 10, step = 5;
		view.mouseDown;
		10.do { 0.1.wait; x = x + step; view.uv.mouseMove(x) };
		10.do { 0.1.wait; x = x - step; view.uv.mouseMove(x) };
	};
	1.wait;

	NTMI.g.setFrontText("click and drag mainVol to change main volume");
	4.do { |i|
		var mainSl = NTMI.g.main.mainSl;
		0.5.wait;
		10.do {
			0.1.wait; mainSl.valueAction = mainSl.value * 1.05;
		};
		10.do {
			0.1.wait; mainSl.valueAction = mainSl.value / 1.05;
		};
	};
	1.wait;
	MFdef(\mainVol).(1);

	(1..3).do { |i| NTMI.slots.endAt(i) };
	4.do { |i| NTMI.ndefs.wrapAt(i).vol_(0.25) };
	NTMI.slots.playAt(0);



	NTMI.g.setFrontText("Each sound has presets - see e.g. slot 1:");
	MFdef(\showPopItems).value(
		NdefPreset(\bleepo).getSetNames,
		NTMI.g.main.prePops[0]
	);
	3.wait;

	NTMI.g.setFrontText("Change presets with popup menu:");
	6.do {
		1.wait;
		NTMI.g.main.prePops[0].valueAction_(
			NdefPreset(NTMI.ndefs[0]).settings.size.rand
		);
	};

	NTMI.g.setFrontText("See them in detail on the presets gui");
	1.wait;
	defer {
		Butz(\NTMI).run(\presets);
		Window.find(\presets).moveTo(968.0, 100.0);
		NTMI.pre.butAction(0);
	};
	6.do {
		1.wait;
		NTMI.g.main.prePops[0].valueAction_(
			NdefPreset(NTMI.ndefs[0]).settings.size.rand
		);
	};


	NTMI.g.setFrontText("Select sound processes on left popup:");
	MFdef(\showPopItems).value(
		NTMI.slots.choices[0],
		NTMI.g.main.popups[0]
	);
	3.wait;

	6.do {
		1.wait;
		NTMI.g.main.popups[0].valueAction_(
			NTMI.slots.choices[0].size.rand
		);
		NTMI.slots.playAt(0);
		NTMI.pre.butAction(0);
	};

	NTMI.g.setFrontText("Influx - the NTMI concept for intuitive playing:");
	Butz(\NTMI).run(\inphlux);
	NTMI.inphlux.resetInvals;

	// move mouse between x 0-130, y 0-210
	playInfluxByMouse = TaskProxy({
		var ioUV = NTMI.inph.ioUV;
		var xmax = 130, ymax = 210, x, y;
		600.do {
			x = xmax.rand; y = ymax.rand;
			ioUV.mouseDown(x, y);
			10.do {
				x = (x + 10.rand2).fold(xmax * 0.25, xmax * 0.75);
				y = (y + 10.rand2).fold(ymax * 0.25, ymax * 0.75);
				ioUV.mouseMove(x, y);
				0.1.wait;
			};
			ioUV.mouseUp(x, y);
		}
	}).clock_(AppClock).play;

	2.wait;
	NTMI.g.setFrontText("Change left side influx inputs by mouse:");

	3.wait;
	NTMI.g.setFrontText("... change zoom to set amount of influence:");
	(1,0.95..0.49).do { |num|
		NTMI.g.main.rMViews[0].valueAction_(num);
		0.5.wait;
	};

	NTMI.g.setFrontText("... also works with multiple sounds\n\n\n");
	NTMI.close(\presets);
	Butz(\NTMI).run(\slotSounds);
	4.do { |i| 1.wait; NTMI.slots.playAt(i) };
	1.wait;
	NTMI.g.setFrontText("... also when sounds and presets change\n\n\n");
	12.do { 0.5.wait; NTMI.pre.stepNdefInf(NTMI.ndefs.choose, 1) };

	NTMI.close(\slotSounds);

	3.wait;


	NTMI.g.setFrontText("Change influx weight presets: preUp, preDown\n\n\n");
	8.do {
		1.wait;
		NTMI.g.main.rMViews[[1, 2].choose].uv.mouseDown
	};
	1.wait;
	NTMI.inph.setWPreIndex(0);


	3.wait;
	NTMI.g.setFrontText("Choose from various main effects ... ");
	Butz(\NTMI_DEMO).run(\mainFX);
	3.wait;
	NTMI.g.setFrontText("Click MainFX button left for down, mid for rand, right for up");
	8.do {
		var but = NTMI.g.main.mfxBut;
		1.wait;
		but.mouseDown(but.bounds.width.rand.postln);
	};

	NTMI.g.setFrontText("Play from physical interfaces - See Butz->NTMI_Demo page!");
	2.wait;
	Butz.curr_(\NTMI_Demo);


	playInfluxByMouse.stop;

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

	NTMI.g.setFrontText("*** % done! ***\n\n".postf(myName));
	1.wait;
	NTMI.g.setFrontText("NTMI Demo ...");
	1.wait;
	NTMI.g.setFrontText("NTMI ...");
	1.wait;
	NTMI.g.setFrontText("");

}).clock_(AppClock);
)

