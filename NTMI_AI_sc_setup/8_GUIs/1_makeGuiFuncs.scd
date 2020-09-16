// all window making functions go here:

g.screenScale = min(Window.availableBounds.width / 1920,
	Window.availableBounds.height / 1177);

g.makeGui = ();

// this func reuses or rebuilds existing windows
MFdef(\makeGui).add(\frontOrRemake, { |name, remake = false|
	var nameSym = name.asSymbol;
	var foundWins = Window.findAll(nameSym);
	var defaultBounds = g.defaultWinBounds[nameSym];

	remake = remake or: { foundWins.isNil or: { foundWins.isEmpty } };

	if (remake) {
		foundWins.do(_.close);
		g.makeGui[nameSym].value(g.makeGui, nameSym);
		if (defaultBounds.notNil) {
			"default bounds for %: %\n".postf(nameSym, defaultBounds);
			foundWins = Window.findAll(name);
			foundWins.do(_.bounds = defaultBounds);
		};
	} {
		// "to front: ".post; foundWins.postln;
		foundWins.do { |win|
			win.front;
		}
	};
	foundWins.do(_.alpha_(0.8));
});

/*
z = NdefGui(Ndef(\allArm));
g.tuneNameView(s);
*/

g.tuneNameView = { |q, obj|
	if (obj.respondsTo(\nameView)) {
		obj.nameView.font_(Font("Helvetica", 16))
		.stringColor_(Color.white)
		.background_(Color.blue)
	} {
		"g.tuneNameView: obj % has no nameView.".postf(obj.cs)
	};
	obj
};

// catch all windows positions
/*
Window.getAll.postcs;
*/
(
// these are the default positions:
g.defaultWinBoundsList = [ [ "MakeGui", Rect(0.0, 180.0, 170.0, 580.0) ],
	[ "NTMI_Main", Window.availableBounds ],
	[ "inphluxInOut", Rect(675.0, 778.0, 680.0, 340.0) ],
	[ "NdefGui_liveInput", Rect(971.0, 557.0, 394.0, 180.0) ],
	[ "slotSounds", Rect(726.0, 138.0, 782.0, 720.0) ],
	[ "allPresets", Rect(725.0, 289.0, 487.0, 500.0) ],
	[ "randomOrbitz", Rect(768.0, 967.0, 434.0, 188.0) ],
	[ "ndefMixer", Rect(200.0, 289.0, 684.0, 500) ],
	[ "mainFX", Rect(1396.0, 373.0, 524.0, 782.0) ],

	[ "ntmi", Rect(42.0, 2.0, 700.0, 462.0) ],
	[ "nanoKtl", Rect(128.0, 42.0, 912.0, 194.0) ],
	[ "uc4", Rect(1166.0, 412.0, 490.0, 510.0) ],
	[ "chanTest", Rect(743.0, 348.0, 400.0, 400.0) ],
];

g.defaultWinBounds = ();
g.defaultWinBoundsList.do { |pair|
	g.defaultWinBounds.put(pair[0].asSymbol, pair[1]);
};
);

g.makeGui.z_setAll = {
	Window.setAll(g.defaultWinBoundsList);
	nil;
};

g.makeGui.z_CLOSEALL = {
	Window.allWindows.do { |w| if (w != g[\MakeGui]) { try { w.close } } };
	nil;
};


g.makeGui.ndefMixer = { |dict, name = \ndefMixer|
	var ndefMixer = NdefMixer(s, 24);
	ndefMixer.parent.name_(name);
	g[name] = ndefMixer;
	ndefMixer.skipjack.dt = 0.5;
	ndefMixer.moveTo(5, 5);
	g[\ndefMixer].arGuis.do(q.tuneNameView(_));
	q.tuneNameView(g[\ndefMixer].editGui);
	// set popupmenu to 'activeProxies' ?
	// ndefMixer.parent.view.children.first.children.first.children[0].valueAction_(1);
	ProxyMeter.addMixer(ndefMixer);
	ProxyMeter.skipjack.dt = 0.2;
	defer ({ ProxyMeter.hideKrs }, 2);

	ndefMixer
};

g.makeGui.liveInput = { |dict, name = \liveInput|
	g.liveGui = q.liveInput.gui.name_(name).moveTo(600, 5);
	g.tuneNameView(g.liveGui);
	g.liveGui;
};

g.makeGui.mainFX = { |dict, name = \mainFX|
	g.guiMaFX = q.mFX.gui(name, 40);
	g.guiMaFX.moveTo(790, 1200);
};

g.makeGui.nanoKtl = { |dict, name = \nanoKtl|
	g.nanoKtl = q.nktl.gui;
	g.nanoKtl;
};

g.makeGui.ntmi = {
	try { Window.find("ntmi").close };
	try {
		var ntg = MKtl(\ntmi).gui;
		ntg.views.detect { |vw| vw.element.name == \enc }.view.centered_(true);
	};
};

g.uc4 !? {
	g.makeGui.uc4 = {
		var uc4gui = g.uc4.gui;
		uc4gui.views.keep(8).do { |view| view.view.centered = true };
		uc4gui
	}
};



MKtl.all['ferrari'] !? { g.makeGui.ferrari = { q.ferr.mktl.gui } };

g.makeGui.oscSimulator = { |dict, name = \oscSimulator|
	var bounds = Window.flipY(g.main.oscBut.absoluteBounds).height_(150).moveBy(0, -220);
	var win = Window(name, bounds).front;
	win.view.addFlowLayout;
	StaticText(win, (bounds.extent * (0.99@0.24)).asRect)
	.string_(" - TEST THAT OSC IS WORKING - \nSimulate OSC signals from XOSC:");

	[ MFdef(\simulateXOSC), MFdef(\realXOSC) ].do { |mfdef|
		Button(win, bounds.extent * (0.45@0.2))
		.states_([[mfdef.key]])
		.action_(mfdef);
	};

	StaticText(win, (bounds.extent * (0.99@0.16)).asRect)
	.string_("TODO: Sim. OSC signals from NTMI:");

	[ MFdef(\simulateNTMI), MFdef(\realNTMI) ].do { |mfdef|
		Button(win, bounds.extent * (0.45@0.2))
		.states_([[mfdef.key]])
		.action_(mfdef)
		.enabled_(false);
	};
};

g.makeGui[\MakeGui] = { |dict, name = \MakeGui|
	var winHeight = (g.makeGui.size + 3 * 35);
	var w = Window(name,
		Rect(5,
			150,
			170,
			winHeight
		)
	);
	w.alwaysOnTop_(true).background_(Color.red).front;
	w.addFlowLayout;

	// g.makeGui.keys(Array).sort.do ...
	[
		'NTMI_Main',
		'inphlux',
		'liveInput',
		'slotSounds',
		'allPresets',
		'randomOrbitz',
		'ndefMixer',
		'mainFX',
		"- interfaces -",
		'ntmi',
		'nanoKtl',
		'ferrari',
		'uc4',
		//		'xoscMTPads',
		"- helpers -",
		//		'oscSimulator',
		'chanTest',
		'MakeGui',
		'z_setAll',
		'z_CLOSEALL',
	].do { |key|
		Button(w, 160@28)
		.font_(Font("Monaco", 18))
		.states_([[key, Color.white, Color.grey(0.8, 0.4) ]]).action_ { |but, mod = 0|
			defer ({ MFdef(\makeGui).value(key.asSymbol, mod.isAlt) }, 0.1);
		}
	};
	g[name] = w;
};

