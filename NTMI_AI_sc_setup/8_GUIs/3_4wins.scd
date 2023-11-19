//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// make 4 NdefGuis for them
// these show changes for all of them
/*
q.ndefs

g.makeGui.slotSounds;

*/

var q, g;
NTMI.g = NTMI.g ? (); // global dict
q = NTMI.q;
g = NTMI.g;


g.makeGui.slotSounds = { |dict, name = \slotSounds|
	var scbn = Window.availableBounds;
	var maxHeight = 440; // scbn.height - 20;
	var maxNumSlots = (maxHeight / 2 - 50 / 20 + 0.2).asInteger;


	var w = Window(name,
		Rect(scbn.width - 800,
			scbn.height - 650,
			780,
			min(800, maxHeight))
	).front;
	var slotNames = q.ndefs.collect(_.key);

	("maxNumSlots: " + maxNumSlots).postln;
	w.addFlowLayout;
	w.alpha_(0.8);
	g.ndefPreGuis = q.ndefs.keep(4).collect { |px, i|
		var ndefPre = NdefPreset(px);
		var gui = NdefPresetGui(ndefPre, maxNumSlots, w);
		var zonebounds = gui.zone.bounds;
		gui.zone.bounds = zonebounds.height = zonebounds.height + 10;
		if (i.odd) { w.view.decorator.shift(0, 10) };
		g.tuneNameView(gui.proxyGui);
		gui;
	};

	g.ndefPreGuis.do { |gui| gui.skipjack.dt_(0.1) };
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
	w;
};
