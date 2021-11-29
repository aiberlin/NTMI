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

g.butzNames = [
	'miniMax',
	'StartupDial',
	'Main_NTMI',
	'inphlux',
	'liveInput',
	'slotSounds',
	'presets',
	'randomOrbitz',
	'ndefMixer',
	'mainFX',
	'-interfaces-',
	//	'nUFO',
	'nanoKtl',
	//	'ferrari',
	//	'uc4',
	'-helpers-',
	'chanTest',
	'plotTree',
	// 'meters',
	// 'scope',
	'setAll',
	'CLOSEALL',
];

// Butz.clear;
Butz.numButz = g.butzNames.size + 2;
// just do the names to create the proper order in Butz:
g.butzNames.do (Butz.add(_));

// set Butz window style params:
Butz.style;
Butz.numButz = 22; // leave two for customization
Butz.style.winCol = Color.red(1, 0.8);
Butz.style.winExtent_(120@16);
Butz.style.font.name = g.fontName;
Butz.style.font.size = 16;

Butz.show.updateButtons;

// then add some one-liners:
Butz.addMiniMax;

Butz.add('StartupDial', { StartupFile.dialog });

Butz.add('setAll', { WinBounds.restoreAll });

Butz.add('plotTree', { s.plotTree });
// Butz.add('scope', { s.scope(s.options.numOutputBusChannels) });
// Butz.add('meters', { s.meter.window.name_(\meters) });

Butz.add('chanTest', { g.makeGui.chanTest });

Butz.add('CLOSEALL', {
	Window.allWindows.do { |w| if (w != Butz.w) { w.close } }
});

// the main NTMI windows - funcs defined in other GUI files
Butz.add('Main_NTMI', { WinBounds.showOrMake('Main_NTMI')});
WinBounds.addMake('Main_NTMI', {
	g.makeGui[\Main_NTMI].value;
	g.main.w.alpha_(g.alpha ? 0.8);
});

Butz.add('inphlux', { WinBounds.showOrMake('inphlux') });
WinBounds.addMake('inphlux', { g.makeGui.inphlux.alpha_(g.alpha) });

Butz.add(\liveInput, { WinBounds.showOrMake(\liveInput) });
WinBounds.addMake(\liveInput, { |dict, name = \liveInput|
	g.liveGui = q.liveInput.gui.name_(name).moveTo(600, 5);
	g.tuneNameView(g.liveGui);
	g.liveGui.parent.alpha_(g.alpha);
});

Butz.add('slotSounds', { WinBounds.showOrMake('slotSounds') });
WinBounds.addMake('slotSounds', { g.makeGui.slotSounds.alpha_(g.alpha) });

Butz.add('presets', { WinBounds.showOrMake('presets') });
WinBounds.addMake('presets', { g.makeGui.presets.alpha_(g.alpha) });

Butz.add('randomOrbitz', { WinBounds.showOrMake('randomOrbitz') });
WinBounds.addMake('randomOrbitz', { g.makeGui.randomOrbitz.alpha_(g.alpha) });


//////// ndefmixer - add to WinBounds call to Butz,
Butz.add(\ndefMixer, {  WinBounds.showOrMake(\ndefMixer); });

///// then add makefunc to WinBounds:
WinBounds.addMake(\ndefMixer, { |dict, name = \ndefMixer|
	// numItems could also be q.process.allNames.size;
	var ndefMixer = NdefMixer(s, max(q.process.allNames.size, 24));
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

//

// add a gui makeFunc for MainFX:
Butz.add('mainFX', { WinBounds.showOrMake('mainFX', ) });
WinBounds.addMake('mainFX', { |dict, name = \mainFX|
	g.makeGui.mainFX;
	q.mfx.win.front.name_(name);
});

/// some more for extra interfaces - MKtls
Butz.add(\nanoKtl, { WinBounds.showOrMake(\nanoKtl) });
WinBounds.addMake(\nanoKtl, { |dict, name = \nanoKtl|
	g.nanoKtl = q.nktl.gui; g.nanoKtl.parent;
});

// move these later
if (MKtl.all['ntmi'].notNil) {
	Butz.actions.addAfter(\nUFO, { WinBounds.showOrMake(\nUFO) }, '-interfaces-');
	Butz.updateButtons.showButs(Butz.actions.size);
	WinBounds.addMake(\nUFO, {
		var ntg = MKtl(\ntmi).gui;
		ntg.parent.name_(\nUFO);
		ntg.views.detect { |vw| vw.element.name == \enc }.view.centered_(true);
	});
};

if (MKtl.all['uc4'].notNil) {
	Butz.actions.addAfter(\uc4, { WinBounds.showOrMake(\uc4) }, '-interfaces-');
	Butz.updateButtons.showButs(Butz.actions.size);
	Butz.add(\uc4, { WinBounds.showOrMake(\uc4) });
	WinBounds.addMake(\uc4, {
		var uc4gui = g.uc4.gui;
		uc4gui.views.keep(8).do { |view| view.view.centered = true };
		uc4gui.parent.alpha_(0.8);
	});
};

if (MKtl.all['ferrari'].notNil) {
	Butz.actions.addAfter(\ferrari, { WinBounds.showOrMake(\ferrari) }, '-interfaces-');
	Butz.updateButtons.showButs(Butz.actions.size);
	WinBounds.addMake(\ferrari, {
		g.ferrari = MKtl.all['ferrari'].gui;
		g.ferrari.parent.name_(\ferrari);
	})
};

/////////// and these are all the stored bounds:
WinBounds.stored.putAll( (
	'randomOrbitz': Rect(768.0, 817.0, 434.0, 188.0),
	'slotSounds': Rect(726.0, 138.0, 782.0, 720.0),
	'MakeGui': Rect(0.0, 180.0, 170.0, 580.0),
	'uc4': Rect(1166.0, 412.0, 490.0, 510.0),

	'chanTest': Rect(743.0, 348.0, 400.0, 400.0),
	'ndefMixer': Rect(200.0, 289.0, 684.0, 540.0),
	'mainFX': Rect(1156.0, 223.0, 524.0, 782.0),
	'inphlux': Rect(675.0, 665.0, 680.0, 340.0),
	'ntmi': Rect(42.0, 2.0, 700.0, 462.0),

	'presets': Rect(725.0, 289.0, 487.0, 500.0),
	'Main_NTMI': Rect(0.0, 0.0, 1680.0, 1005.0),
	'NdefGui_liveInput': Rect(971.0, 557.0, 394.0, 180.0),
	'nanoKtl': Rect(128.0, 42.0, 912.0, 194.0)
) );

)
