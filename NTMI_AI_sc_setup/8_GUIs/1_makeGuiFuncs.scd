// all window making functions go here:

g.screenScale = min(Window.availableBounds.width / 1920,
	Window.availableBounds.height / 1177);

g.makeGui = ();

// this func reuses or rebuilds existing windows
MFdef(\makeGui).add(\frontOrRemake, { |name, remake = false|
	var foundWins = Window.findAll(name);
	var newWin;
	remake = remake or: { foundWins.isNil or: { foundWins.isEmpty } };
	if (remake) {
		// "closing: ".post; foundWins.postln;
		foundWins.do(_.close);
		g.makeGui[name.asSymbol].value(g.makeGui, name);
		if (name.notNil) {
			try {
				Window.findAll(name).do(_.bounds = g.defaultWinBounds[name])
			};
		};
	} {
		// "to front: ".post; foundWins.postln;
		foundWins.do(_.front)
	};
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

// these are the default positions:
g.defaultWinBoundsList = [
	[ "MakeGui", Rect(0.0, 202.0, 170.0, 520.0) ],
	[ "inphlux", Rect(100, 665.0, 680.0, 340.0) ],
	[ "NdefGui_liveInput", Rect(600.0, 5.0, 394.0, 194.0) ],
	[ "masterFX", Rect(966.0, 373.0, 524.0, 782.0) ],
	[ "nanoKtl", Rect(435.0, 51.0, 913.0, 202.0) ],
	[ "ndefMixer", Rect(28.0, 14.0, 684.0, 273.0) ],
//	[ "ndefPresets", Rect(5.0, 755.0, 487.0, 400.0) ],
	[ "slotSounds", Rect(880.0, 367.0, 782.0, 610.0) ],
	[ "xosc", Rect(965.0, 15.0, 910.0, 380.0) ],
	// [ "xoscSimulator", Rect(1380.0, 824.0, 262.0, 100) ]
];

g.defaultWinBounds = ();
g.defaultWinBoundsList.do { |pair|
	g.defaultWinBounds.put(pair[0].asSymbol, pair[1]);
};

g.makeGui.z_setAll = {
	Window.setAll(g.defaultWinBoundsList);
	nil;
};

g.makeGui.z_CLOSEALL = {
	Window.allWindows.do { |w| if (w != g[\MakeGui]) { try { w.close } } };
	nil;
};


g.makeGui.ndefMixer = { |dict, name = \ndefMixer|
	var ndefMixer = NdefMixer(s, 12);
	ndefMixer.parent.name_(name);
	g[name] = ndefMixer;
	ndefMixer.skipjack.dt = 0.5;
	ndefMixer.moveTo(5, 5);
	g[\ndefMixer].arGuis.do(q.tuneNameView(_));
	q.tuneNameView(g[\ndefMixer].editGui);
	// set popupmenu to 'activeProxies' ?
	// ndefMixer.parent.view.children.first.children.first.children[0].valueAction_(1);
	ProxyMeter.addMixer(ndefMixer);
	defer ({ ProxyMeter.hideKrs }, 2);

	ndefMixer
};

g.makeGui.liveInput = { |dict, name = \liveInput|
	g.liveGui = q.liveInput.gui.name_(name).moveTo(600, 5);
	g.tuneNameView(g.liveGui);
	g.liveGui;
};

g.makeGui.masterFX = { |dict, name = \masterFX|
	g.guiMaFX = q.mFX.gui(name, 40);
	g.guiMaFX.moveTo(790, 1200);
};

g.makeGui.nanoKtl = { |dict, name = \nanoKtl|
	g.nanoKtl = q.nktl.gui;
	g.nanoKtl;
};

g.uc4 !? { g.makeGui.uc4 = { g.uc4.gui } };

MKtl.all['ferrari'] !? { g.makeGui.ferrari = { q.ferr.mktl.gui } };

g.makeGui.xoscSimulator = { |dict, name = \xoscSimulator|
	var bounds = Window.flipY(g.main.oscBut.absoluteBounds).height_(100).moveBy(0, -120);
	var win = Window(\xoscSimulator, bounds).front;
	win.view.addFlowLayout;
	StaticText(win, (bounds.extent * (0.99@0.38)).asRect)
	.string_("Simulate random OSC signals from an xosc, to test that OSC is working:");

	[ MFdef(\switchToSim), MFdef(\switchToXOSC) ].do { |mfdef|
		Button(win, bounds.extent * (0.45@0.3))
		.states_([[mfdef.key]])
		.action_(mfdef);
	};
};


g.makeGui[\MakeGui] = { |dict, name = \MakeGui|
	var winHeight = (g.makeGui.size + 2 * 35);
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
		'MakeGui',
		'NTMI_Main',
		'xosc', 'xoscMTPads', 'xoscSimulator',
		'inphlux',
		'slotSounds',
		'liveInput',
		'ndefMixer',
		'masterFX',
		'nanoKtl',
		'ferrari',
		'uc4',
	//	'ndefPresets',
		'z_CLOSEALL',
		'z_setAll'
	].do { |key|
		Button(w, 160@28)
		.font_(Font("Monaco", 18))
		.states_([[key, Color.white, Color.grey(0.8, 0.4) ]]).action_ { |but, mod = 0|
			defer ({ MFdef(\makeGui).value(key.asSymbol, mod.isAlt) }, 0.1);
		}
	};
	g[name] = w;
};

