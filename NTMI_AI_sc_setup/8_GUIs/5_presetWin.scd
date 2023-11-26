////// function to make a presetWin if needed

var q = NTMI.q;
var g = NTMI.g;

(
WinBounds.addMake(\presets, { |dict, name = \presets|
	var px = NTMI.ndefs[0];
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
	.action_({ NTMI.pre.openPresetFile });

	NTMI.pre.butUpdate = {
		var butNames = butrow.collect { |but| but.states[0][0] };
		var newNames = NTMI.slots.actives.collect(_.key);
		if (newNames != butNames) {
			"preset gui> newNames: % \n".postf(newNames);
			butrow.do { |but, i|
				var newstates = but.states.do(_.put(0, newNames[i]));
				but.states = newstates;
			}
		}
	};

	NTMI.pre.openPresetFile = {
		ppg.object.storePath.openOS;
	};

	NTMI.pre.setPxInWin = { |dict, proxy|
		ppg.object_(NdefPreset(proxy));
	};

	NTMI.pre.butAction = { |dict, i|
		var but = butrow[i];
		var px = q.ndefs[i];
		// px.resume.play;
		currPreset = NdefPreset(px);
		NTMI.pre.setPxInWin(px.postcln);
		w.addHalo(\active, px); //
		w.addHalo(\active1, i);
	};

	butrow = q.ndefs.collect({|px|
		var name = px.key;
		Button(vlv1, Rect(0,0,100, 30))
		.states_([
			[name], 			// state 0: grey;	stopped unconnected
			[name, Color.black, Color.new255(132, 247, 132)],// state 1: lightgr playing unconnected
			[name, Color.black, Color.new255(238, 118, 0)], // state 2: orange	stopped connected
			[name, Color.black, Color.green(0.62)], 		// state 3: green 	playing connected
		])
	});

	butrow.do({ |but, i|
		but.action_({ |b| NTMI.pre.butAction(i) })
	});

	w.addHalo(\butrow, butrow);

	Button(vlv1, Rect(0,0,100, 30)).states_([["Edit Preset"]]).action_({
		Document( ppg.object.asString, ppg.object.settingsString);
		unixCmd("open" + quote(ppg.object.storePath));
	});

	EZPopUpMenu(vlv1, Rect(0,0,100, 60), 'choose_pre', q.process.allNames, { |pop|
		pop.item.postcs;
		NTMI.pre.setPxInWin(Ndef(pop.item));
	}, layout: \vert);

	Button(vlv1, Rect(0,0,100, 30)).states_([["play at 0.25"]]).action_({
		ppg.object.proxy.set(\amp, 0.25).play(vol: 0.25);
	});

	pp = NdefPreset(px);
	ppg = NdefPresetGui(pp, 20, vlv2);
	ng = ppg.proxyGui;
	ppg.skipjack.dt=0.1;

	g.tuneNameView(ng);
	butrow[0].doAction;

	SkipJack({
		NTMI.pre.butUpdate;
		butrow.do({ |but, i|
			var ndef = NTMI.slots.actives[i];
			var playState = (ndef.monitor.notNil and: { ndef.monitor.isPlaying });
			var isInPresetGui = (ng.object === ndef).binaryValue * 2;
			but.value_( playState.binaryValue + isInPresetGui)
		});
	}, 0.2, { w.isClosed }, \presetWin);
	w;
});
)
