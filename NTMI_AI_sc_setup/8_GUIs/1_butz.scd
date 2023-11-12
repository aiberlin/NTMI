// all window making functions go here:
(
q = q ? (); // global dict
g = g ? (); // gui-related dict

//// set global prefs here:
g.alpha = g.alpha ? 0.8;
// g.fontName = g.fontName ? Font.defaultMonoFace;
g.fontName = g.fontName ? Font.defaultSansFace;

// contains the previous GUI-making functions
g.makeGui = g.makeGui ? ();

g.screenScale = min(Window.availableBounds.width / 1920,
	Window.availableBounds.height / 1177);

// make nameViews bigger and better
g.tuneNameView = { |q, obj|
	if (obj.respondsTo(\nameView)) {
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

Butz(\NTMI).clear;

Butz.curr_(\NTMI);

g.butzNames = [
	'miniMax',
	'Main_NTMI',
	'inphlux',
	'liveInput',
	'slotSounds',
	'presets',
	'randomOrbitz',
	'ndefMixer',
	'mainFX',
	'-interfaces-',
	'-Config-',
	'-Tutorial-'
];

// Butz.clear;
Butz.numButz = g.butzNames.size + 3;

// set Butz window style params:
Butz.style;
Butz.style.winCol = Color.red(1, 0.8);
Butz.style.winExtent_(120@16);
Butz.style.font.name = Font.defaultMonoFace;
Butz.style.font.size = 16;

Butz.show;

// add some top-level one-liners:
Butz.addMiniMax;
Butz.add('StartupDial', { StartupFile.dialog });
Butz.add('CLOSEALL', { Window.allWindows.do { |w| if (w != Butz.w) { w.close } } });

//////// ndefmixer - add to WinBounds call to Butz, make func later
Butz.add(\ndefMixer, {  WinBounds.showOrMake(\ndefMixer); });

// add a gui makeFunc for MainFX:
Butz.add('mainFX', { WinBounds.showOrMake('mainFX') });
WinBounds.addMake('mainFX', { |dict, name = \mainFX|
	g.makeGui.mainFX;
	q.mfx.win.front.name_(name);
});

Butz.add('meters', { s.meter; Window.find(s.name).name_(\meters) });
Butz.add('scope', { s.scope(s.options.numOutputBusChannels) });

/// some general helpers
Butz.add('setAll', { WinBounds.restoreAll });
Butz.add('plotTree', { s.plotTree });
Butz.add('chanTest', { g.makeGui.chanTest });



/****
Make an NTMI separate Butz for windows and functions
- many functions defined in other GUI files
***/

// add the names to create the proper order:
g.butzNames.do (Butz(\NTMI).add(_));

Butz(\NTMI).add('Main_NTMI', { WinBounds.showOrMake('Main_NTMI')});
WinBounds.addMake('Main_NTMI', {
	g.makeGui[\Main_NTMI].value;
	g.main.w.alpha_(g.alpha ? 0.8);
});

// only add wsetta to Butz if the gui func for it exists:
if (WinBounds.makeFuncs[\wsetta].notNil) {
	Butz(\NTMI).add(\wsetta, { WinBounds.showOrMake(\wsetta) });
};

// shortcuts to switch Butz pages from Main NTMI window
Butz('NTMI').add('-interfaces-', { Butz.curr_('interfaces') });
Butz('NTMI').add('-Config-', { Butz.curr_('NTMI_Config') });
Butz('NTMI').add('-Tutorial-', { Butz.curr_('NTMI_Tutorial') });


/// put the interfaces in a separate Butz list,
/// add detailed funcs later
Butz('interfaces').addMiniMax;

[ 	'nUFO',
	'nanoKtl',
	'ferrari',
	'uc4'
].do { |ifName|
	Butz(\interfaces).add(ifName, { ifName.postln });
};


Butz(\NTMI).add('inphlux', { WinBounds.showOrMake('inphlux') });
WinBounds.addMake('inphlux', { g.makeGui.inphlux.alpha_(g.alpha) });

Butz(\NTMI).add(\liveInput, { WinBounds.showOrMake(\liveInput) });
WinBounds.addMake(\liveInput, { |dict, name = \liveInput|
	g.liveGui = q.liveInput.gui.name_(name).moveTo(600, 5);
	g.tuneNameView(g.liveGui);
	ProxyMeter.addNdefGui(g.liveGui);
	g.liveGui.parent.alpha_(g.alpha);
});

Butz(\NTMI).add('slotSounds', { WinBounds.showOrMake('slotSounds') });
WinBounds.addMake('slotSounds', { g.makeGui.slotSounds.alpha_(g.alpha) });

Butz(\NTMI).add('presets', { WinBounds.showOrMake('presets') });
WinBounds.addMake('presets', { g.makeGui.presets.alpha_(g.alpha) });

Butz(\NTMI).add('randomOrbitz', { WinBounds.showOrMake('randomOrbitz') });
WinBounds.addMake('randomOrbitz', { g.makeGui.randomOrbitz.alpha_(g.alpha) });


///// add \ndefMixer makefunc to WinBounds:
WinBounds.addMake(\ndefMixer, { |dict, name = \ndefMixer|
	// numItems could also be q.process.allNames.size;
	var maxVisible = 21; // (Window.screenBounds.height - 30 / 20);
	var ndefMixer = NdefMixer(s, min(q.process.allNames.size, maxVisible));
	ndefMixer.parent.name_(name);
	g[name] = ndefMixer;
	ndefMixer.moveTo(5, 5);
	// set popupmenu to 'activeProxies' ?
	// ndefMixer.parent.view.children.first.children.first.children[0].valueAction_(1);
	ProxyMeter.addMixer(ndefMixer);
	// save CPU by slowing down polling:
	ndefMixer.skipjack.dt = 0.4;
	ProxyMeter.skipjack.dt = 0.2;
	defer ({ ProxyMeter.hideKrs }, 1);

	g[\ndefMixer].arGuis.do(g.tuneNameView(_));
	g.tuneNameView(g[\ndefMixer].editGui);
	// alwways return the window,
	// so WinBounds can resize and place it
	ndefMixer.parent;
});



/////// the INTERFACES Butz: /////////////
// function to load an interface file or gui:
MFdef(\loadInterfaceFile).add(\load, { |name, filepath|
	if (PathName(filepath).isRelativePath) {
		filepath = (q.dir.ntmi +/+ filepath);
	};
	if (MKtl.all[name].isNil) {
		filepath.postcs.loadPaths;
	};
	WinBounds.addMake(name, {
		q.ferrgui = MKtl(name).gui.showLabels;
		q.ferrgui.parent
	});
	WinBounds.showOrMake(name);
});

MFdef(\addInterfaceFile).add(\butz, { |name, filepath|
	Butz(\interfaces).add(name, {
		MFdef(\loadInterfaceFile).(name, filepath);
	});
});

// add 4 interfaces
MFdef(\addInterfaceFile).(\ferrari,
	"3_interfaces/optionals/3_ferrari.scd");

MFdef(\addInterfaceFile).(\uc4,
	"3_interfaces/optionals/2_uc4.scd");

MFdef(\addInterfaceFile).(\nanoKtl,
	"3_interfaces/optionals/7_nanoktl.scd");

MFdef(\addInterfaceFile).(\nUFO,
	"3_interfaces/optionals/1*nufo.scd");

Butz(\NTMI_Config).clear;
Butz(\NTMI_Config).addMiniMax;
Butz(\NTMI_Config).add(\userDir, { q.dir.user.openOS });
Butz(\NTMI_Config).add(\userPrefs, { q.prefs.userPrefPath.openOS });
Butz(\NTMI_Config).add(\userPOOL, { q.dir.userPOOL.openOS });
Butz(\NTMI_Config).add(\soundfiles, { q.dir.userPOOL.openOS });
Butz(\NTMI_Config).add('open setup', { q.dir.ntmi.openOS });

Butz(\NTMI_Config).add('open quark', { Quark("NTMI").localPath.openOS });


/////////// and these are all the stored bounds:
WinBounds.stored.putAll( (
	'Main_NTMI': Rect(0.0, 0.0, 1680.0, 1005.0),
	'NTMI': Rect(42.0, 2.0, 700.0, 462.0),
	'inphlux': Rect(675.0, 665.0, 680.0, 340.0),
	'NdefGui_liveInput': Rect(971.0, 557.0, 394.0, 180.0),
	'slotSounds': Rect(726.0, 138.0, 782.0, 720.0),
	'presets': Rect(725.0, 289.0, 487.0, 440),
	'randomOrbitz': Rect(768.0, 817.0, 434.0, 188.0),

	'ndefMixer': Rect(200.0, 289.0, 684.0, 440),
	'mainFX': Rect(1156.0, 223.0, 524.0, 440),
	'chanTest': Rect(743.0, 348.0, 400.0, 400.0),

	'nanoKtl': Rect(128.0, 42.0, 912.0, 194.0),
	'uc4': Rect(1166.0, 412.0, 490.0, 510.0),
).collect(WinBounds.limitRectToScreen(_)));
)
