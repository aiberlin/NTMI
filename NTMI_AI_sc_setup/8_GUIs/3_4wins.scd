//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// make 4 NdefGuis for them
// these show changes for all of them
/*
q.ndefs
*/

g.makeGui.slotSounds = { |dict, name = \slotSounds|
	var scbn = Window.availableBounds;
	var w = Window(name,
		Rect(scbn.width - 800,
			scbn.height - 650,
			780,
			600)
	).front;
	var slotNames = q.ndefs.collect(_.key);

	w.addFlowLayout;
	w.alpha_(0.8);
	g.ndefPreGuis = q.ndefs.keep(4).collect { |px, i|
		var ndefPre = NdefPreset(px);
		var gui = NdefPresetGui(ndefPre, 11, w);
		if (i.odd) { w.view.decorator.shift(0, 10) };
		g.tuneNameView(gui.proxyGui);
		gui;
	};
	g[name] = w;
	// w.bounds = w.bounds.moveTo(450, 500);

	SkipJack({
		var newNames = q.ndefs.collect(_.key);
		if (newNames != slotNames) {
			// "update 4 slotSounds!".postln;
			g.ndefPreGuis.do { |npg, i|
				var newPre = NdefPreset(q.ndefs[i]);
				if (npg.object_ != newPre) { npg.object = newPre }
			}
		};
		slotNames = newNames;
	}, 0.2, { w.isClosed }, \presetWin);

};

g.makeGui.slotSounds;

