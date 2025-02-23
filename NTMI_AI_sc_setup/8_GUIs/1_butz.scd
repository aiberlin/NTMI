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
	'InfluxMixer',
	'liveInput',
	'presets',
	'slotSounds',
	'randomOrbitz',
	'ndefMixer',
	'mainFX',
];

// Butz.clear;
Butz.numButz = [NTMI.g.butzNames.size + 6, NTMI.optionalNames.size + 4, 18].maxItem;

// set Butz window style params:
Butz.style.alpha = NTMI.g.alpha;
Butz.style.winCol = Color.red(1, 0.8);
Butz.style.winExtent_(60@16);
Butz.style.font.name = Font.defaultMonoFace;
Butz.style.font.size = (18 * (NTMI.g.screenScale ** 0.5)).round;
"// Butz font: %\n\n".postf(Butz.style.font);

Butz.show;
Butz.w.alpha_(NTMI.g.alpha);

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

Butz.add(\OSC_trace, {
	OSCFunc.trace(OSCFunc.classVars[3].not, true);
});
Butz.add(\MIDI_trace, {
	MIDIFunc.trace(MIDIFunc.classVars[2].not, true);
});

/// some general helpers
Butz.add('setAll', { WinBounds.restoreAll });
Butz.add('chanTest', { WinBounds.showOrMake(\chanTest) });
Butz.add('plotTree', { s.plotTree });


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


Butz(\NTMI).add('inphlux', { WinBounds.showOrMake('inphlux') });

Butz(\NTMI).add(\liveInput, { WinBounds.showOrMake(\liveInput) });
WinBounds.addMake(\liveInput, { |dict, name = \liveInput|
	var ndefGui = Ndef(\liveInput).gui;
	var win = ndefGui.parent;
	NTMI.g.tuneNameView(ndefGui);
	ProxyMeter.addNdefGui(ndefGui);
	win.alpha_(NTMI.g.alpha);
	defer({ win.name = name }, 0.2);
	win.alpha_(NTMI.g.alpha);
});

Butz(\NTMI).add('slotSounds', { WinBounds.showOrMake('slotSounds') });

Butz(\NTMI).add('presets', { WinBounds.showOrMake('presets') });

Butz(\NTMI).add('randomOrbitz', { WinBounds.showOrMake('randomOrbitz') });


// /////// the INTERFACES Butz: /////////////
/// put the interfaces in a separate Butz list,
/// add detailed funcs later
Butz('interfaces').clear;
Butz('interfaces').addMiniMax;


NTMI.updateInterfaceButz = {
	Butz(\interfaces).clear.addMiniMax;

	Butz(\interfaces).add(\findConnect, {
		Task {
			LoadMe("3_interfaces/6_TryLoad_MKtls.scd", NTMI.dir.setup);
			0.5.wait;
			MKtl.all.do { |mk|
				mk.name;
				if (mk.hasDevice) {
					WinBounds.showOrMake(mk.name)
				}
			}
		}.play(AppClock);
	});
	Butz(\interfaces).add(\InfluxMixer, {
		WinBounds.showOrMake(\InfluxMixer)
	});


	(NTMI.interfaces.keys(Array).sort ++ '-loadable:-'
		++ NTMI.interfacesToShow.removeAll(NTMI.interfaces.keys)).do { |name, mktl|
		name = name.asSymbol;
		Butz(\interfaces).add(name, {
			defer {
				"%: check for MKtl ...\n".postf(name);
				if (MKtl.all[name].isNil) {
					"%: tryLoadMKtl\n".postf(name);
					NTMI.tryLoadMKtl(name)
				} {
					if (MKtl.all[name].hasDevice) {
						"% : already open\n".postf(name);
					} {
						"& : try openDevice\n".postf(name);
						MKtl.all[name].openDevice;
					};
				};
				if (MKtl.all[name].isNil) {
					"*** MKtl % does not exist! \n".postf(name);
				}{
					WinBounds.showOrMake(name);
				};
				NTMI.updateInterfaceButz;
			}
		});

		if (name != '-loadable:' and: WinBounds.makeFuncs[name].isNil) {
			"WinBounds.addMake(%)\n".postf(name.cs);
			WinBounds.addMake(name, {
				var mktl = MKtl.all[name];
				var mkgui;
				if (mktl.isNil) {
					"*** MKtl % does not exist! \n".postf(name);
					"could not make window for it".postln;
					nil;
				} {
					mkgui = mktl.gui.showLabels;
					mkgui.parent.alpha_(NTMI.g.alpha);

					// moved to MKtlGui: devicebutton can close with mod keys
					mkgui.parent;
				}
			});
		};
	};
};
NTMI.updateInterfaceButz;


(
Butz(\Personalize).clear;
Butz(\Personalize).addMiniMax;
Butz(\Personalize).add('Overview', {
	Document.open(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/1_Configure_setup.scd")
});

Butz(\Personalize).add('Presets_doc', {
	Document.open(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/2_adding_presets.scd")
});
Butz(\Personalize).add('Presets_dir', {
	(NTMI.dir.userPOOL +/+ "/2_process/presets/").openOS
});

Butz(\Personalize).add(\userDir_POOL, {
	Document.open(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/3a_userDir_POOL.scd")
});
Butz(\Personalize).add(\POOL_open, { NTMI.dir.userPOOL.openOS });

Butz(\Personalize).add('Process_doc', {
	Document.open(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/3b_adding_sound_processes.scd")
});
Butz(\Personalize).add(\Process_open, { (NTMI.dir.userPOOL +/+"2_process").openOS });

Butz(\Personalize).add('Interface_doc', {
	Document.open(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/4a_Connecting_new_interfaces.scd")
});

Butz(\Personalize).add(\SoundF_doc, {
	Document.open(NTMI.dir.setup +/+ "/HOW_TO_PERSONALIZE/5_Adding_soundfiles.scd")
});

Butz(\Personalize).add(\SoundF_open, { (NTMI.dir.user +/+ "soundfiles").openOS });
Butz(\Personalize).add('Setup_Quark', { NTMI.dir.setup.openOS });
);

)

