////// function to make a presetWin if needed

(
g.makeGui.presets = { |dict, name = \presets|
	var pxs = q.ndefs;
	var px = q.currxoscPx ? q.ndefs[0];
	var currPreset;
	var pp, w, ppg, ng, hlv, vlv1, vlv2, butrow, randerButs;
	w = Window(name, Rect(450, 0, 387+100, 440)).front;
	// q.ndefPresetGlobalWin = w; // glob main win!
	hlv = HLayoutView(w, w.bounds.moveTo(0,0));
	vlv1 = VLayoutView(hlv, Rect.new(0,0, 100, hlv.bounds.height))
		.background_(Color.green.alpha_(0.2));
	vlv2 = VLayoutView(hlv, Rect.new(0,0, 410, hlv.bounds.height));

	Button(vlv1, Rect(0,0,100, 30)).states_([["UPDATE"]])
	.action_(MFdef('preButUpdate'));

	Button(vlv1, Rect(0,0,100, 30)).states_([["open file"]])
	.action_(MFdef('openPresetFile'));

	MFdef('preButUpdate').add(\set, {
		var butNames = butrow.collect { |but| but.states[0][0] };
		var newNames = q.slots.actives.collect(_.key);
		if (newNames != butNames) {
			butrow.do { |but, i|
				var newstates = but.states.do(_.put(0, newNames[i]));
				but.states = newstates;
			}
		}
	});

	MFdef('openPresetFile').add(\open, {
		ppg.object.storePath.openOS;
	});

	MFdef('setPxInPreWin').add(\set, { |proxy|
		ng.object_(proxy);
		ppg.object_(NdefPreset(proxy));
	});

	MFdef('preButAction').add(\set, { |i|
		var but = butrow[i];
		var px = q.ndefs[i];
		// px.resume.play;
		currPreset = px.getHalo(\ndefPreset);
		MFdef('setPxInPreWin').value(px.postcln);
		w.addHalo(\active, px); //
		w.addHalo(\active1, i);
	});

	butrow = q.ndefs.collect({|px|
		var name = px.key;
		Button(vlv1, Rect(0,0,100, 30))
		.states_([
			[name], 			// state 0: grey;	stopped unconnected
			[name, Color.black, Color.new255(132, 247, 132)],// state 1: lightgr playing unconnected
			[name, Color.black, Color.new255(238, 118, 0)], // state 2: orange	st. connected
			[name, Color.black, Color.green(0.62)], 		// state 3: green 	pl. connected
		])
	});

	butrow.do({ |but, i|
		but.action_({ |b| MFdef('preButAction').value(i) })
	});

	w.addHalo(\butrow, butrow);

	Button(vlv1, Rect(0,0,100, 30)).states_([["Edit Preset"]]).action_({
		Document( ppg.object.asString, ppg.object.settingsString);
		unixCmd("open" + quote(ppg.object.storePath));
	});

	EZPopUpMenu(vlv1, Rect(0,0,100, 60), 'choose_pre', q.process.allNames, { |pop|
		pop.item.postcs;
		MFdef('setPxInPreWin').value(Ndef(pop.item));
	}, layout: \vert);

	Button(vlv1, Rect(0,0,100, 30)).states_([["play at 0.25"]]).action_({
		ppg.object.proxy.set(\amp, 0.25).play(vol: 0.25);
	});


	/*
	// RandomOrbits Stuff here, kick out!
	Button(vlv1, Rect(0,0, 48, 30))
	.states_([['- - - - - -']])
	//	.action( 	q.uniWin.getHalo(\ndefGui).object_(Ndef(\nix)) ) // erase sliders....
	;
	randerButs = 4.collect({|i|
	Button(vlv1, Rect(0,0, 48, 30))
	.states_([
	[\rand ++ (#[10, 1, -1, -10].wrapAt(i))],
	])
	});
	randerButs.do({|but, i|
	but.action_({|b|
	var nuSeed = q.incrementSeed(px, #[10, 1, -1, -10].wrapAt(i) );
	//			currPreset.setRand(1, except: [\amp, \direct], seed: nuSeed); // except still broken !!!
	currPreset.setRand(1, seed: nuSeed);
	})
	});
	*/
	pp = px.getHalo(\ndefPreset); // assumes there is! ToDo: default to making it!
	ppg = NdefPresetGui(pp, 0, vlv2);
	ng = NdefGui(px, 20, vlv2);
	ng.skipjack.dt=0.1;

	q.uniWin = w;
	q.uniWin.addHalo(\proxyPresetGui, ppg);
	q.uniWin.addHalo(\ndefGui, ng);
	q.uniWin.addHalo(\active, px);
	q.uniWin.addHalo(\active1, 0);

	g.tuneNameView(ng);

	butrow[0].doAction;

	SkipJack({
		var active1 = w.getHalo(\active1);
		var playStates = pxs.collect({|px| p[px].monitor.isPlaying
			and: {p[px].paused.not } and: {p[px].monitor.vol > 0}
		});
		MFdef('preButUpdate').value;
		// butrow.collect({|but, i|  if(playStates[i]){but.value_(2)} });
		butrow /*.reject({|b, i| i == active1 })*/
		.do({|b, i|
			b.value_( playStates[i].binaryValue )
		});
		butrow[active1].value_(playStates[active1].binaryValue + 2)
	}, 0.2, { w.isClosed }, \presetWin);
	w;
}
);
