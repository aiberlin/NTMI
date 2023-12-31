// all window making functions go here:
(
var q, g;
NTMI.g = NTMI.g ? (); // dict for gui stuff
q = NTMI.q;
g = NTMI.g;


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

)

