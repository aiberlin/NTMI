// all window making functions go here:
(
var q, g;
NTMI.g = NTMI.g ? (); // dict for gui stuff
q = NTMI.q;
g = NTMI.g;

// use NTMI.g.bounds to test for different screen sizes,
// e.g. NTMI.g.bounds = Rect(0,0,1024, 768);
g.bounds = g.bounds ? Window.availableBounds;

g.screenScale = min(g.bounds.width / 1920,
	Window.availableBounds.height / 1177);

//// set global prefs here:
g.alpha = g.alpha ? 0.8;
g.fontName = g.fontName ? Font.defaultSansFace;
g.font = Font(g.fontName, (36 * g.screenScale).round);
g.fatfont = Font(g.fontName, (72 * g.screenScale).round);

g.butGrey = Color.grey(0.3, 0.3);
g.butGreen = Color.green(1, 0.7);


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
Butz.style.winExtent_(60@16);
Butz.style.font.name = Font.defaultMonoFace;
Butz.style.font.size = (18 * (NTMI.g.screenScale ** 0.5)).round;
Butz.style.font.postcs;

Butz.show;
Butz.w.bounds;

// add some top-level one-liners:
Butz.addMiniMax;
Butz.add('StartupDial', { StartupFile.dialog });
Butz.add('CLOSEALL', { Window.allWindows.do { |w| if (w != Butz.w) { w.close } } });

//////// ndefmixer - add to WinBounds call to Butz, make func later
Butz.add(\ndefMixer, {  WinBounds.showOrMake(\ndefMixer); });
//////// TdefAllGui - add to WinBounds call to Butz, make func later
Butz.add('Tdef.all', {  WinBounds.showOrMake('Tdef.all'); });
//////// TdefAllGui - add to WinBounds call to Butz, make func later
Butz.add('Pdef.all', {  WinBounds.showOrMake('Pdef.all'); });

// add a gui makeFunc for MainFX:
Butz.add('mainFX', { WinBounds.showOrMake('mainFX') });

Butz.add('meters', { s.meter; Window.find(s.name).name_(\meters) });
Butz.add('scope', { s.scope(s.options.numOutputBusChannels) });

/// some general helpers
Butz.add('setAll', { WinBounds.restoreAll });
Butz.add('plotTree', { s.plotTree });
Butz.add('chanTest', { WinBounds.showOrMake(\chanTest) });




/****
Make an NTMI separate Butz for windows and functions
- many functions defined in other GUI files
***/

// add the names to create the proper order:
g.butzNames.do (Butz(\NTMI).add(_));

Butz(\NTMI).add('Main_NTMI', { WinBounds.showOrMake('Main_NTMI')});

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

Butz(\NTMI).add(\liveInput, { WinBounds.showOrMake(\liveInput) });
WinBounds.addMake(\liveInput, { |dict, name = \liveInput|
	var ndefGui = Ndef(\liveInput).gui.postln;
	var win = ndefGui.parent;
	NTMI.g.tuneNameView(ndefGui);
	ProxyMeter.addNdefGui(ndefGui);
	win.alpha_(NTMI.g.alpha);
	defer({ win.name = name.postln }, 0.2);
	win;
});

Butz(\NTMI).add('slotSounds', { WinBounds.showOrMake('slotSounds') });

Butz(\NTMI).add('presets', { WinBounds.showOrMake('presets') });

Butz(\NTMI).add('randomOrbitz', { WinBounds.showOrMake('randomOrbitz') });

WinBounds.addMake('Tdef.all', { TdefAllGui(16).parent });
WinBounds.addMake('Pdef.all', { PdefAllGui(16).parent });

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
	ndefMixer.parent;
});



/////// the INTERFACES Butz: /////////////
// function to load an interface file or gui:
NTMI.loadInterfaceFile = { |dict, name, filepath|
	if (PathName(filepath).isRelativePath) {
		filepath = (NTMI.dir.setup +/+ filepath);
	};
	if (MKtl.all[name].isNil) {
		filepath.postcs.loadPaths;
	};
	if (WinBounds.makeFuncs[name].isNil) {
		WinBounds.addMake(name, {
			MKtl(name).gui.showLabels.parent
		});
	};

	WinBounds.showOrMake(name);
};

NTMI.addInterfaceFile = { |dict, name, filepath|
	Butz(\interfaces).add(name, {
		NTMI.loadInterfaceFile(name, filepath);
	});
};

// add 4 interfaces
NTMI.addInterfaceFile(\ferrari,
	"3_interfaces/optionals/3_ferrari.scd");

NTMI.addInterfaceFile(\uc4,
	"3_interfaces/optionals/2_uc4.scd");

NTMI.addInterfaceFile(\nanoKtl,
	"3_interfaces/optionals/7_nanoKtl.scd");

NTMI.addInterfaceFile(\nUFO,
	"3_interfaces/nufo/1*nufo.scd");

(
Butz(\NTMI_Config).clear;
Butz(\NTMI_Config).addMiniMax;
Butz(\NTMI_Config).add('Prefs_doc', {
	(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/1_Configure_setup.scd").openOS
});
Butz(\NTMI_Config).add(\Prefs_file, { NTMI.prefs.userPrefPath.openOS });

Butz(\NTMI_Config).add('Presets_doc', {
	(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/2_adding_presets.scd").openOS
});
Butz(\NTMI_Config).add('Presets_dir', {
	(NTMI.dir.userPOOL +/+ "/2_process/presets/").openOS
});

Butz(\NTMI_Config).add(\userDir_POOL, {
	(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/3a_userDir_POOL.scd").openOS
});
Butz(\NTMI_Config).add(\POOL_open, { NTMI.dir.userPOOL.openOS });

Butz(\NTMI_Config).add('Process_doc', {
	(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/3b_adding_sound_processes.scd").openOS
});
Butz(\NTMI_Config).add(\Process_open, { (NTMI.dir.userPOOL +/+"2_process").openOS });

Butz(\NTMI_Config).add('Interface_doc', {
	(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/4a_Connecting_new_interfaces.scd").openOS
});

Butz(\NTMI_Config).add(\SoundF_doc, {
	(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/5_Adding_soundfiles.scd").openOS
});

Butz(\NTMI_Config).add(\SoundF_open, { NTMI.dir.userPOOL.openOS });
Butz(\NTMI_Config).add('Setup_Quark', { NTMI.dir.setup.openOS });
);

/////////// and these are all the stored bounds:
WinBounds.stored.clear.putAll( (
	'Main_NTMI': NTMI.g.bounds,
	'inphlux': Rect(875.0, 665.0, 680.0, 340.0),
	'liveInput': Rect(200, 5, 394.0, 180.0),
	'slotSounds': Rect(726.0, 5, 782.0, 460),
	'presets': Rect(184.0, 158.0, 487.0, 440.0),
	'randomOrbitz': Rect(237.0, 627.0, 434.0, 188.0),

	'ndefMixer': Rect(200.0, 10, 400, 431),
	'mainFX': Rect(1156.0, 4, 524.0, 659.0),
	'chanTest': Rect(743.0, 348.0, 400.0, 400.0),

).collect(WinBounds.limitRectToScreen(_, 0, NTMI.g.bounds)));

// make MKtlGUIs fit on raspi screen,
// needed for nanoKtl:
if (NTMI.hasSmallScreen) {
	MKtlGUI.maxSize = 780;
	MKtlGUI.minViewSize = 32;
};
)

