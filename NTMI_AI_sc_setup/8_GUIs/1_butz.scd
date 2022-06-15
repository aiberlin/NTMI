// all window making functions go here:
(
q = q ? ();
g = g ? ();

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
		obj.nameView.font_(g.fontName, 16)
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

Butz.clear;
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
	// '-interfaces-',
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

// then add some one-liners:
Butz.addMiniMax;
Butz.add('StartupDial', { StartupFile.dialog });
Butz.add('CLOSEALL', { Window.allWindows.do { |w| if (w != Butz.w) { w.close } } });
Butz.add(\ndefMixer, {  WinBounds.showOrMake(\ndefMixer); });

//////// ndefmixer - add to WinBounds call to Butz,

// add a gui makeFunc for MainFX:
Butz.add('mainFX', { WinBounds.showOrMake('mainFX') });
WinBounds.addMake('mainFX', { |dict, name = \mainFX|
	g.makeGui.mainFX;
	q.mfx.win.front.name_(name);
});

Butz.add('meters', { s.meter.window.name_(\meters) });
Butz.add('scope', { s.scope(s.options.numOutputBusChannels) });

/// some helpers
Butz.add('setAll', { WinBounds.restoreAll });
Butz.add('plotTree', { s.plotTree });
Butz.add('chanTest', { g.makeGui.chanTest });

// the main NTMI windows - funcs defined in other GUI files
// just do the names to create the proper order in Butz:
g.butzNames.do (Butz(\NTMI).add(_));

Butz(\NTMI).add('Main_NTMI', { WinBounds.showOrMake('Main_NTMI')});
WinBounds.addMake('Main_NTMI', {
	g.makeGui[\Main_NTMI].value;
	g.main.w.alpha_(g.alpha ? 0.8);
});

// only add wsetta to Butz if the gui func exists:
if (WinBounds.makeFuncs[\wsetta].notNil) {
	Butz(\NTMI).add(\wsetta, { WinBounds.showOrMake(\wsetta) });
};

Butz('interfaces').addMiniMax;

Butz('NTMI').add('-interfaces-', { Butz.curr_('interfaces') });

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


///// then add makefunc to WinBounds:
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

Butz(\interfaces).add('nUFO', {
	if (MKtl.all['nUFO'].isNil) {
		[
			"3_interfaces/optionals/1_osc_nufo.scd",
			"3_interfaces/optionals/1b_ntmi_nufo.scd",
			"3_interfaces/optionals/1c_allLEDs_nufo.scd",
			"3_interfaces/optionals/1d_pads2bits_nufo.scd"
		].do { |path| (q.dir.user +/+ path).postcs.loadPaths };
	};
	WinBounds.addMake('nUFO', {
		MKtl(\nUFO).gui.showLabels.parent
	});
	WinBounds.showOrMake('nUFO');
});

Butz(\interfaces).add('ferrari', {
	if (MKtl.all['ferrari'].isNil) {
		(q.dir.user +/+ "3_interfaces/optionals/3_ferrari.scd".postcs).loadPaths;
	} {
		WinBounds.addMake('ferrari', {
			q.ferrgui = MKtl(\ferrari).gui.showLabels;
			q.ferrgui.parent
		});
		WinBounds.showOrMake('ferrari')
	};
});

Butz(\interfaces).add('uc4', {
	if (MKtl.all['uc4'].isNil) {
		(q.dir.user +/+ "3_interfaces/optionals/2_uc4.scd".postcs).loadPaths;
	} {
		WinBounds.addMake('uc4', {
			MKtl('uc4').gui.showLabels.parent
		});
		WinBounds.showOrMake('uc4')
	};
});

Butz(\interfaces).add('nanoKtl', {
	if (MKtl.all['nanoKtl'].isNil) {
		(q.dir.user +/+ "3_interfaces/optionals/7_nanoktl.scd".postcs).loadPaths;
	} {
		WinBounds.addMake('nanoKtl', {
			MKtl('nanoKtl').gui.showLabels.parent
		});
		WinBounds.showOrMake('nanoKtl')
	};
});


/////////// and these are all the stored bounds:
WinBounds.stored.putAll( (
	'randomOrbitz': Rect(768.0, 817.0, 434.0, 188.0),
	'slotSounds': Rect(726.0, 138.0, 782.0, 720.0),
//	'MakeGui': Rect(0.0, 180.0, 170.0, 580.0),
	'uc4': Rect(1166.0, 412.0, 490.0, 510.0),

	'chanTest': Rect(743.0, 348.0, 400.0, 400.0),
	'ndefMixer': Rect(200.0, 289.0, 684.0, 440),
	'mainFX': Rect(1156.0, 223.0, 524.0, 440),
	'inphlux': Rect(675.0, 665.0, 680.0, 340.0),
	'NTMI': Rect(42.0, 2.0, 700.0, 462.0),

	'presets': Rect(725.0, 289.0, 487.0, 440),
	'Main_NTMI': Rect(0.0, 0.0, 1680.0, 1005.0),
	'NdefGui_liveInput': Rect(971.0, 557.0, 394.0, 180.0),
	'nanoKtl': Rect(128.0, 42.0, 912.0, 194.0)
).collect(WinBounds.limitRectToScreen(_)));
)
