g.makeGui = g.makeGui ? ();

g.foundToFront = { |q, name|
	var found = Window.findAll(name);
	var numFound = found.size;
	if (numFound > 0) { found.do(_.front) };
	numFound > 0;
};

g.makeGui.pxmix = {
	if (g.foundToFront("NdefMixer").not) {
		g.pxmix = NdefMixer(s, 12);
		g.pxmix.skipjack.dt = 0.5;
		g.pxmix.moveTo(5, 5);
		// set popupmenu to 'activeProxies'
		g.pxmix.parent.view.children.first.children.first.children[0].valueAction_(1);
		ProxyMeter.addMixer(g.pxmix);
		defer ({ ProxyMeter.hideKrs }, 1);
	}
};

g.makeGui.inputGui = {
	if (g.foundToFront("liveInput").not) {
		g.liveGui = q.liveInput.gui.name_(\liveInput).moveTo(600, 5)
	}
};

g.makeGui.mfx = {
	if (g.foundToFront("master").not) {
		g.guiMaFX = q.mFX.gui('ma master', 40);
		g.guiMaFX.moveTo(790, 1200);
	}
};

g.makeGui.nanoKontrol2 = {
	if (g.foundToFront("nanoKtl").not) { q.midi.ktl.gui }
};

g.makeGui.simulator = {
	if (g.foundToFront("TdefGui_xoscSim").not) {
		Tdef(\xoscSim).gui
	}
};

// g.makeGui[\cLOSEaLL] = { };

