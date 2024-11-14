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
	var vbounds = win.view.bounds;
	// a zone for the extra buttons etc
	var butzone = CompositeView(win, Rect(160, 0, 750, 25)).background_(Color.rand);

	// a userview to draw the numeric values on
	var uv = UserView(win, vbounds.top_(vbounds.height).height_(30))
	.background_(Color.grey);

	try { win.alpha_(NTMI.g.alpha) };
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

	butzone.addFlowLayout(2@2, 1@1);
	Button(butzone, 80@20)
	.states_([[\oscConnect, nil, Color.grey(0.85)], [\connected, nil, Color.green]])
	.action_({ OSCdef(\flatcat2mktl).enable });

	Button(butzone, 80@20)
	.states_([[\flatcatSim, nil, Color.grey(0.85)], [\flatcatSim, nil, Color.green]])
	.action_({ |b| var t = Tdef(\flatcatSim); var pls = t.isPlaying;
		if (pls) { t.stop } { t.play }; b.value = pls.not.binaryValue });
	Button(butzone, Rect(240, 2, 80, 20))
	.states_([[\flatcatViz, nil, Color.grey(0.85)]])
	.action_({ WinBounds.showOrMake(\flatcatViz) });

	EZPopUpMenu(butzone, 120@20, \infMode, [\rel, \abs], { |pop|
		if (pop.value == 0) { NTMI.flatcat.setRel } { NTMI.flatcat.setAbs }
	}, labelWidth: 60);
	EZSlider(butzone, 200@20, \zoom, \unipolar,
		{ |sl| NTMI.flatcat.zoom = sl.value},
		labelWidth: 40);
	win;
});
try { Window.find(\flatcat).close };
WinBounds.showOrMake(\flatcat);
);
