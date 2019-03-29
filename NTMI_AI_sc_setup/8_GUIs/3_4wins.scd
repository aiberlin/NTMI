//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// make 4 NdefGuis for them
// these show changes for all of them

g.makeGui.slotSounds = { |dict, name = \slotSounds|
	var w = Window(name, Rect(600, 0, 400, 800)).front;
	w.addFlowLayout;
	g.ndefGuis = q.ndefs.keep(4).collect { |px, i|
		var gui = NdefGui(px, 8, w);
		w.view.decorator.nextLine.shift(0, 10);
		gui.skipjack.dt = 0.03;
		gui;
	};
	g[name] = w;
	w.bounds = w.bounds.moveTo(450, 500);
};

