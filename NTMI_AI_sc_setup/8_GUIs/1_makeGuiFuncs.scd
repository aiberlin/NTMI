g.makeGui = g.makeGui ? ();

g.closeGuis = { |q, name|
	Window.allWindows.do { |w| if (w.name.contains(name)) { try { w.close } } }
};

g.makeGui.pxmix = {
	g.closeGuis ("NdefMixer");
	g.pxmix = NdefMixer(s, 12);
	g.pxmix.skipjack.dt = 0.5;
	g.pxmix.moveTo(5, 5);
	// set popupmenu to 'activeProxies'
	g.pxmix.parent.view.children.first.children.first.children[0].valueAction_(1);
	ProxyMeter.addMixer(g.pxmix);
	defer ({ ProxyMeter.hideKrs }, 1);
};

g.makeGui.inputGui = {
	g.closeGuis ("liveInput");
	g.liveGui = q.liveInput.gui.name_(\liveInput).moveTo(600, 5)
};

g.makeGui.mfx = {
	g.closeGuis ("ma master");
	g.guiMaFX = q.mFX.gui('ma master', 40);
	g.guiMaFX.moveTo(790, 1200);
};

g.makeGui.nanoKontrol2 = { q.midi.ktl.gui };

g.makeGui.simulator = { Tdef(\xoscSim).gui };

// g.makeGui[\cLOSEaLL] = { };

