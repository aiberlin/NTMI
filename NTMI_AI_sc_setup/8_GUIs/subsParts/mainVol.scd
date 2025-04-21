// ** mainVol view

var g = NTMI.g;

if (g.main.mainVolZone.isNil or: {
	g.main.mainVolZone.isClosed }) {
	// make a test window
	var w = Window("mainVol", Rect(0, 0, 394.0, 79.0)).front;
	g.main.mainVolZone = w.view;
};

g.main.mainSl = MView(
	0.5,
	NTMI.g.main.mainVolZone,
	NTMI.g.main.mainVolZone.bounds.extent.asRect,
	MFdef(\mainVolGet).value.unbubble,
	g.main.w
);

g.main.mainSl.uv.alpha_(0.7).refresh;
g.main.mainSl.label_(\mainVol);
g.main.mainSl.dict[\knobCol] = Color.grey(0, 0.7);
g.main.mainSl.dict.round_(1/100);
g.main.mainSl.dict.font_(g.font);

g.main.mainSl.drawFunc.add(\label, {
	Pen.stringCenteredIn(
		g.main.mainSl.label,
		g.main.mainSl.bounds.moveTo(0,0),
		NTMI.g.fontFat,
		Color.blue
	)
});

g.main.mainSl.dict[\focusCol] = Color.grey(1.0, 0.8);
g.main.mainSl.dict[\backCol] = Color.grey(1.0, 0.6);
g.main.mainSl.uv.focus(true).refresh;


if (NTMI.usesMainFX) {
	g.main.mainSl.putDict(\myspec, [0, 4, \amp]);
	g.main.mainSl.action.add(\setMain, { |mv|
		MFdef(\mainVol).(mv.value);
	});
	g.main.updateMainVol = {
		var nuval = MFdef(\mainVolGet).value.unbubble ? 1;
		if (g.main.mainSl.value != nuval) {
			g.main.mainSl.value = nuval
		};
	};
} {
	g.main.mainSl.putDict(\myspec, \mainVolS.asSpec);
	g.main.mainSl.action.add(\setMain, { |mv|
		s.volume.volume = mv.value;
	});
	g.main.updateMainVol = {
		var nuval = s.volume.volume;
		if (g.main.mainSl.value != nuval) {
			g.main.mainSl.value = nuval
		};
	};
};

