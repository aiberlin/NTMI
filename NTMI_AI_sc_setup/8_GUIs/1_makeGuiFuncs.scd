q.makeGui = q.makeGui ? ();

q.closeGuis = { |q, name|
	Window.allWindows.do { |w| if (w.name.contains(name)) { try { w.close } } }
};

q.makeGui.pxmix = {
	q.closeGuis ("NdefMixer");
	q.pxmix = NdefMixer(s, 6);
	q.pxmix.skipjack.dt = 0.5;
	q.pxmix.moveTo(5, 5);
	ProxyMeter.addMixer(q.pxmix);
};
// s.scope(q.numChans).window.bounds_(Rect(00, 1000, 261, 250));


q.makeGui.inputGui = {
	q.closeGuis ("liveInput");
	q.liveGui = q.liveInput.gui.name_(\liveInput).moveTo(600, 5)
};

q.makeGui.mfx = {
	q.closeGuis ("ma master");
	q.guiMaFX = q.mFX.gui('ma master', 40);
	q.guiMaFX.moveTo(790, 1200);
};

// q.makeGui.xosc is in separate file

////// entangled GUI and logic:
// q.inphluxGui - needs separation of logic from attachButtons
/// "3_4wins.scd" <-this could load later
// "ndef-menu-choice.scd" <- this too?
