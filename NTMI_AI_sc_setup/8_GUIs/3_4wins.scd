 //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// make 4 NdefGuis for the processes in the 4 NTMI slots.
// when playing with influx, these show changes for the active ones.
/*

*/

var q, g;
NTMI.g = NTMI.g ? (); // global dict
q = NTMI.q;
g = NTMI.g;


WinBounds.addMake('slotSounds', { |dict, name = \slotSounds|
	// g.bounds; // screenbounds
	var maxHeight = 480; // g.bounds.height - 20;
	var maxNumSlots = (maxHeight / 2 - 96 / 20 + 0.2).asInteger;
	var slotNames = q.ndefs.collect(_.key);

	var w = Window(name,
		Rect(g.bounds.width - 800,
			g.bounds.height - 650,
			780,
			min(800, maxHeight - 20))
	).front;

	("slotSounds Gui maxNumSlots: " + maxNumSlots).postln;
	w.addFlowLayout;
	w.alpha_(NTMI.g.alpha);
	w.background_(Color.grey(0.5));
	g.ndefPreGuis = q.ndefs.keep(4).collect { |px, i|
		var ndefPre = NdefPreset(px);
		var gui = NdefPresetGui(ndefPre, maxNumSlots, w);
		var zonebounds = gui.zone.bounds;
		gui.zone.bounds = zonebounds.height_(zonebounds.height + 10);
		if (i.odd) { w.view.decorator.shift(0, 10) };
		g.tuneNameView(gui.proxyGui);
		ProxyMeter.addNdefGui(gui.proxyGui);
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
});
