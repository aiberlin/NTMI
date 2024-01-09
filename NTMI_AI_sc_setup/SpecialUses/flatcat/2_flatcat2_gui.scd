///// GUI stuff:
/* // put at the end of your startup:

WinBounds.showOrMake(\flatcat);

*/

(
NTMI.addInterfaceFile(\flatcat, "SpecialUses/flatcat/flatcat_gui.scd");

// add number readouts to gui:
WinBounds.addMake(\flatcat, {
	var mg = MKtl(\flatcat).gui.showLabels;
	var win = mg.parent;
	// a userview to draw the numeric values on
	var uv = UserView(win, win.view.bounds.top_(200).height_(30))
	.background_(Color.grey);
	win.bounds = win.bounds.height_(win.bounds.height + 30);

	uv.drawFunc = { |uv|
		var string = MKtl(\flatcat).elAt.deviceValue.collect { |val|
			(val.round(0.001).asString ++ " ").clipExtend(5)
		};
		Pen.stringCenteredIn(string.join(" "),
			uv.bounds.extent.asRect,
			Font(Font.defaultMonoFace, 16.5),
			Color.green);
	};
	uv.frameRate_(10).animate_(true);

	Button(win, Rect(160, 2, 80, 20))
	.states_([[\oscConnect, nil, Color.grey(0.85)], [\connected, nil, Color.green]])
	.action_({ OSCdef(\flatcat2mktl).enable });

	Button(win, Rect(240, 2, 80, 20))
	.states_([[\flatcatSim, nil, Color.grey(0.85)], [\flatcatSim, nil, Color.green]])
	.action_({ |b| var t = Tdef(\flatcatSim); var pls = t.isPlaying;
		if (pls) { t.stop } { t.play }; b.value = pls.not.binaryValue });
	Button(win, Rect(240, 2, 80, 20))
	.states_([[\flatcatViz, nil, Color.grey(0.85)]])
	.action_({ WinBounds.showOrMake(\flatcatViz) });

	EZPopUpMenu(win, Rect(320, 2, 120, 20), \infMode, [\rel, \abs], { |pop|
		if (pop.value == 0) { NTMI.flatcat.setRel } { NTMI.flatcat.setAbs }
	}, labelWidth: 60);
	EZSlider(win, Rect(440, 2, 200, 20), \zoom, \unipolar,
		{ |sl| NTMI.zooms.flatcat = sl.value},
		labelWidth: 40);

	win;
});
);
