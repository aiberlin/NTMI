////// function to make a presetWin if needed

(
g.makeGui.ndefPresetWin = { |dict, height= 450, left = 0|
//	var pxs = Ndef.dictFor(s).arProxyNames.collect(Ndef(_);
	var pxs = q.ndefs;
	var px = q.currxoscPx ? pxs[0];
	var currPreset, switchPxINGui;
	var pp, w, ppg, ng, hlv, vlv1, vlv2, butrow, randerButs;
	w = Window("basic_presets", Rect(left, 5, 387+100, height)).front;
	// q.ndefPresetGlobalWin = w; // glob main win!
	hlv = HLayoutView(w, w.bounds.moveTo(0,0));
	vlv1 = VLayoutView(hlv, Rect.new(0,0, 100, hlv.bounds.height)).background_(Color.green.alpha_(0.2));
	vlv2 = VLayoutView(hlv, Rect.new(0,0, 410, hlv.bounds.height));

	butrow = pxs.collect({|px|
		var name = px.key;
		Button(vlv1, Rect(0,0,100, 30))
		.states_([
			[name], 								// state 0: grey;	stopped unconnected
			[name, Color.black, Color.new255(132, 247, 132)],// state 1: lightgr	playing unconnected
			[name, Color.black, Color.new255(238, 118, 0)], // state 2: orange	st. connected
			[name, Color.black, Color.green(0.62)], 		// state 3: green 	pl. connected
		])
	});
	w.addHalo(\butrow, butrow);

	butrow.do({|but, i|
		but.action_({|b|
			px = pxs[i];
			q.active.presWin.clear.add(px); // using Set
			// q.active.presWin = px; // not using Set but single instance...
			px.resume.play;
			currPreset = px.getHalo(\ndefPreset);
			switchPxINGui.value(px.postcln);
			w.addHalo(\active, px); //
			w.addHalo(\active1, i);
		})
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
	ng = NdefGui(px, 19, vlv2);
	ng.skipjack.dt=0.1;

	q.uniWin = w;
	q.uniWin.addHalo(\proxyPresetGui, ppg);
	q.uniWin.addHalo(\ndefGui, ng);
	q.uniWin.addHalo(\active, px);
	q.uniWin.addHalo(\active1, 0);

	switchPxINGui = {|px|
		ng.object_(px);
		ppg.object_(currPreset);
	};
	q.switchPxINGui = switchPxINGui;

	SkipJack({
		var active1 = w.getHalo(\active1);
		var playStates = pxs.collect({|px| p[px].monitor.isPlaying
			and: {p[px].paused.not } and: {p[px].monitor.vol > 0}
		});
		// butrow.collect({|but, i|  if(playStates[i]){but.value_(2)} });
		butrow /*.reject({|b, i| i == active1 })*/
		.do({|b, i|
			b.value_( playStates[i].binaryValue )
		});
		butrow[active1].value_(playStates[active1].binaryValue + 2)
	}, 0.2, w.isClosed, "checkplayin");
	w;
}
);

/*
q.makeGui.ndefPresetWin;
q.uniWin.getHalo(\active1);
q.uniWin.getHalo(\active1sy);

Halo.at(q.uniWin);
*/



/*
// let's save ressources -- we dont need this win at all!

//make the win
q.maPresetWin = q.ndefPresetWin;
// q.switchPxINGui( q.ndefs[2] );
q.maPresetWin.view.children.first.children.first.children.wrapAt(8.rand).valueAction_(1); // ugly switch
*/