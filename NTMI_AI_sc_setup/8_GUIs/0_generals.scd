// all window making functions go here:

var q, g;
NTMI.g = NTMI.g ? (); // dict for gui stuff
q = NTMI.q;
g = NTMI.g;


NTMI.close = { |dict, name|	try { Window.find(name).close } };

// use NTMI.g.bounds to test for different screen sizes,
// e.g. NTMI.g.bounds = Rect(0,0,1024, 768);
g.bounds = g.bounds ? Window.availableBounds;

NTMI.g.screenScale = { min(g.bounds.width / 1920,
	Window.availableBounds.height / 1177 ) };

// make MKtlGUIs fit on raspi screen,
// needed for nanoKtl:
if (NTMI.hasSmallScreen) {
	MKtlGUI.maxSize = 780;
	MKtlGUI.minViewSize = 32;
};

//// set global GUI prefs here:
g.alpha = g.alpha ? 0.8;
g.fontName = g.fontName ? Font.defaultSansFace;
g.font = Font(g.fontName, (36 * g.screenScale).round);
g.fontFat = Font(g.fontName, (72 * g.screenScale).round);
g.fontMid = Font(g.fontName, (51 * g.screenScale).round);


g.butGrey = Color.grey(0.3, 0.3);
g.butGreen = Color.green(1, 0.7);


// make nameViews bigger and better
g.tuneNameView = { |q, obj|
	if (obj.respondsTo(\nameView)) {
		// fixed font size
		obj.nameView.font_(Font(g.fontName, 16))
		.stringColor_(Color.white)
		.background_(Color.blue)
	} {
		"g.tuneNameView: obj % has no nameView.".postf(obj.cs)
	};
	obj
};

/*
z = NdefGui(Ndef(\allArm));
g.tuneNameView(s);
*/

WinBounds.addMake('Tdef.all', { TdefAllGui(16).parent.alpha_(NTMI.g.alpha) });
WinBounds.addMake('Pdef.all', { PdefAllGui(16).parent.alpha_(NTMI.g.alpha) });

///// add \ndefMixer makefunc to WinBounds:
WinBounds.addMake(\ndefMixer, { |dict, name = \ndefMixer|
	// numItems could also be NTMI.process.allNames.size;
	var maxVisible = 21; // (Window.screenBounds.height - 30 / 20);
	var ndefMixer = NdefMixer.small(s, min(NTMI.process.allNames.size, maxVisible));
	ndefMixer.parent.name_(name);
	ndefMixer.switchSize(2, true);
	ndefMixer.moveTo(5, 5);
	// set popupmenu to 'activeProxies' ?
	// ndefMixer.parent.view.children.first.children.first.children[0].valueAction_(1);
	ProxyMeter.addMixer(ndefMixer);
	// save CPU by slowing down polling:
	ndefMixer.skipjack.dt = 0.4;
	ProxyMeter.skipjack.dt = 0.2;
	defer ({ ProxyMeter.hideKrs }, 1);

	ndefMixer.arGuis.do(g.tuneNameView(_));
	NTMI.g.tuneNameView(ndefMixer.editGui);
	g.ndefMixer = ndefMixer;
	// alwways return the window,
	// so WinBounds can resize and place it
	ndefMixer.parent.alpha_(NTMI.g.alpha);
});

/////////// and these are all the stored bounds:
WinBounds.stored.clear.putAll(
	(
		'Main_NTMI': NTMI.g.bounds,
		'inphlux': Rect(875.0, 665.0, 680.0, 340.0),
		'liveInput': Rect(200, 5, 394.0, 180.0),
		'slotSounds': Rect(726.0, 5, 782.0, 460),
		'presets': Rect(184.0, 158.0, 487.0, 440.0),
		'randomOrbitz': Rect(237.0, 627.0, 434.0, 188.0),

		'ndefMixer': Rect(200.0, 10, 400, 431),
		'Tdef.all': Rect(130.0, 566.0, 270.0, 350.0),
		'Pdef.all': Rect(400, 566.0, 270.0, 350.0),
		'mainFX': Rect(1156.0, 4, 524.0, 659.0),
		'chanTest': Rect(743.0, 348.0, 400.0, 400.0),
	)
	.collect( WinBounds.limitRectToScreen(_, 0, NTMI.g.bounds) )
);

